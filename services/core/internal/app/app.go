package app

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"sync/atomic"
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

	var isReady int32 = 0

	go func() {
		ticker := time.NewTicker(5 * time.Second)
		for range ticker.C {
			func() {
				ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
				defer cancel()

				if err := db.PingContext(ctx); err != nil {
					atomic.StoreInt32(&isReady, 0)
					healthServer.SetServingStatus("readiness", healthpb.HealthCheckResponse_NOT_SERVING)
				} else {
					atomic.StoreInt32(&isReady, 1)
					healthServer.SetServingStatus("readiness", healthpb.HealthCheckResponse_SERVING)
				}
			}()
		}
	}()

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

func (a *App) Run(ctx context.Context) error {
	grpcListener, err := net.Listen("tcp", ":50051")
	if err != nil {
		slog.Error("gRPC failed to listen", "error", err)
		os.Exit(1)
	}

	errChan := make(chan error, 2)

	go func() {
		slog.Info("HTTP server starting", "addr", a.httpServer.Addr)
		if err := a.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
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
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		_ = a.httpServer.Shutdown(shutdownCtx)
		a.grpcServer.GracefulStop()

		a.shutdown()

		return nil
	}
}

// shutdown releases the resources App owns. The *sql.DB borrows the pgx pool,
// so it must be closed before the pool it wraps.
func (a *App) shutdown() {
	if a.db != nil {
		_ = a.db.Close()
	}
	if a.pool != nil {
		a.pool.Close()
	}
}

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
