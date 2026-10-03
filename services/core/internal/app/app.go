package app

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/lmittmann/tint"
	authv1 "github.com/yappachino-dev/ink/gen/go/pb/auth/v1"
	syncv1 "github.com/yappachino-dev/ink/gen/go/pb/sync/v1"
	vaultv1 "github.com/yappachino-dev/ink/gen/go/pb/vault/v1"
	"github.com/yappachino-dev/ink/services/core/internal/auth"
	"github.com/yappachino-dev/ink/services/core/internal/config"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/email"
	"github.com/yappachino-dev/ink/services/core/internal/store"
	"github.com/yappachino-dev/ink/services/core/internal/sync"
	"github.com/yappachino-dev/ink/services/core/internal/vault"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
)

type App struct {
	cfg *config.Config
	// db borrows pool rather than owning it. Closing db does not close the
	// pool, so shutdown releases them in that order.
	pool       *pgxpool.Pool
	db         *sql.DB
	httpServer *http.Server
	grpcServer *grpc.Server
}

func New(ctx context.Context, cfg *config.Config) (*App, error) {
	pool, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect database: %w", err)
	}

	db := stdlib.OpenDBFromPool(pool)

	if err := database.Migrate(ctx, db); err != nil {
		return nil, fmt.Errorf("failed to migrate database: %w", err)
	}

	queries := store.New(pool)
	transactor := database.NewPgTransactor(pool)

	userRepo := auth.NewPostgresUserRepository(queries)
	tokenRepo := auth.NewPostgresTokenRepository(queries)
	verificationRepo := auth.NewPostgresVerificationRepository(queries)
	vaultRepo := vault.NewPostgresVaultRepository(queries)
	syncRepo := sync.NewPostgresSyncRepository(queries)

	verificationSvc := auth.NewVerificationService(verificationRepo)

	logger := slog.New(tint.NewHandler(os.Stdout, &tint.Options{
		Level: slog.LevelDebug,
	}))

	// Verification-code delivery: real SMTP in production, log output in dev.
	var codeSender auth.CodeSender
	if cfg.Env == config.EnvProduction {
		codeSender = emailCodeSender{sender: email.NewSender(cfg.SMTP)}
	} else {
		codeSender = auth.NewLogCodeSender(logger)
	}

	authSvc := auth.NewAuthService(userRepo, tokenRepo, cfg.JwtSecretKey, 15*time.Minute, 7*24*time.Hour)
	vaultSvc := vault.NewVaultService(transactor, vaultRepo)
	syncSvc := sync.NewSyncService(transactor, syncRepo)
	logOpts := []logging.Option{logging.WithLogOnEvents(
		logging.StartCall, logging.FinishCall,
	)}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			auth.UnaryRateLimitInterceptor(),
			auth.UnaryAuthInterceptor(cfg.JwtSecretKey),
			logging.UnaryServerInterceptor(interceptorLogger(logger), logOpts...),
		),
	)

	authv1.RegisterAuthServiceServer(grpcServer, auth.NewServer(authSvc, verificationSvc, codeSender))
	vaultv1.RegisterVaultServiceServer(grpcServer, vault.NewServer(vaultSvc))
	syncv1.RegisterSyncServiceServer(grpcServer, sync.NewServer(syncSvc))

	healthServer := health.NewServer()
	healthpb.RegisterHealthServer(grpcServer, healthServer)
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)

	watchReadiness(ctx, db, healthServer)

	// Put gin in release mode outside development to silence debug routing
	// logs and disable debug-only behavior.
	if cfg.Env != config.EnvDevelopment {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	r.GET("/healthz", func(c *gin.Context) {
		if err := db.PingContext(c.Request.Context()); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": "unhealthy", "database": "down"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "healthy", "database": "up"})
	})

	return &App{
		cfg:  cfg,
		pool: pool,
		db:   db,
		httpServer: &http.Server{
			Addr:              ":8080",
			Handler:           r,
			ReadHeaderTimeout: 5 * time.Second,
			ReadTimeout:       10 * time.Second,
			WriteTimeout:      15 * time.Second,
			IdleTimeout:       60 * time.Second,
		},
		grpcServer: grpcServer,
	}, nil
}

// Run binds the production ports and hands off to serve.
func (a *App) Run(ctx context.Context) error {
	grpcListener, err := net.Listen("tcp", ":50051")
	if err != nil {
		return fmt.Errorf("gRPC failed to listen: %w", err)
	}

	httpListener, err := net.Listen("tcp", a.httpServer.Addr)
	if err != nil {
		_ = grpcListener.Close()
		return fmt.Errorf("HTTP failed to listen: %w", err)
	}

	return a.serve(ctx, httpListener, grpcListener)
}

// serve runs both listeners and releases what App owns on return, whichever
// way it returns. The crash arm is the reason teardown is a defer: a server
// failing is when cleanup matters most, and it used to skip it entirely.
func (a *App) serve(ctx context.Context, httpListener, grpcListener net.Listener) error {
	defer a.shutdown()

	errChan := make(chan error, 2)

	go func() {
		slog.Info("HTTP server starting", "addr", httpListener.Addr().String())
		if err := a.httpServer.Serve(httpListener); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errChan <- fmt.Errorf("HTTP server crash: %w", err)
		}
	}()

	go func() {
		slog.Info("gRPC server starting", "addr", grpcListener.Addr().String())
		if err := a.grpcServer.Serve(grpcListener); err != nil {
			errChan <- fmt.Errorf("gRPC server crash: %w", err)
		}
	}()

	select {
	case err := <-errChan:
		return err
	case <-ctx.Done():
		return nil
	}
}

// shutdown releases every resource App owns, including a partially built App
// as the tests construct one. Contexts derive from Background on purpose:
// shutdown has to run even though the signal already cancelled ctx.
func (a *App) shutdown() {
	if a.httpServer != nil {
		ctx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		_ = a.httpServer.Shutdown(ctx)
	}

	// GracefulStop blocks until in-flight RPCs drain, so bound it and escalate.
	stopped := make(chan struct{})
	go func() {
		if a.grpcServer != nil {
			a.grpcServer.GracefulStop()
		}
		close(stopped)
	}()

	select {
	case <-stopped:
	case <-time.After(shutdownTimeout):
		if a.grpcServer != nil {
			a.grpcServer.Stop()
		}
	}

	if a.db != nil {
		_ = a.db.Close()
	}
	if a.pool != nil {
		a.pool.Close()
	}
}

const (
	readinessService  = "readiness"
	readinessInterval = 5 * time.Second
	readinessTimeout  = 2 * time.Second
)

// watchReadiness mirrors database reachability into the gRPC health status
// until ctx is cancelled, returning a channel closed once it exits. The cancel
// arm is the point: without it the probe keeps pinging a closed database for
// the rest of the process lifetime, and shutdown never really finishes.
func watchReadiness(ctx context.Context, db *sql.DB, healthServer *health.Server) <-chan struct{} {
	done := make(chan struct{})

	go func() {
		defer close(done)

		ticker := time.NewTicker(readinessInterval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				pingCtx, cancel := context.WithTimeout(ctx, readinessTimeout)
				err := db.PingContext(pingCtx)
				cancel()

				status := healthpb.HealthCheckResponse_SERVING
				if err != nil {
					status = healthpb.HealthCheckResponse_NOT_SERVING
				}
				healthServer.SetServingStatus(readinessService, status)
			}
		}
	}()

	return done
}

// shutdownTimeout bounds each stage of teardown so one stuck listener cannot
// hold the process open past the grace period.
const shutdownTimeout = 5 * time.Second

func interceptorLogger(l *slog.Logger) logging.Logger {
	return logging.LoggerFunc(func(ctx context.Context, lvl logging.Level, msg string, fields ...any) {
		l.Log(ctx, slog.Level(lvl), msg, fields...)
	})
}

// emailCodeSender adapts the SMTP sender to the auth.CodeSender interface.
type emailCodeSender struct {
	sender *email.Sender
}

func (a emailCodeSender) SendCode(_ context.Context, email, code string) error {
	return a.sender.SendVerificationCode(email, code)
}
