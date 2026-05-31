package app

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/lmittmann/tint"
	"github.com/yappachino-dev/ink/services/core/internal/auth"
	"github.com/yappachino-dev/ink/services/core/internal/config"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
	"github.com/yappachino-dev/ink/services/core/internal/sync"
	"github.com/yappachino-dev/ink/services/core/internal/vault"
	authv1 "github.com/yappachino-dev/ink/services/gen/pb/auth/v1"
	syncv1 "github.com/yappachino-dev/ink/services/gen/pb/sync/v1"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
)

type App struct {
	cfg        *config.Config
	db         *sql.DB
	httpServer *http.Server
	grpcServer *grpc.Server
}

func New(ctx context.Context, cfg *config.Config) *App {
	pool, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		panic(fmt.Sprintf("failed to connect database: %v", err))
	}

	db := stdlib.OpenDBFromPool(pool)
	queries := store.New(pool)

	userRepo := auth.NewPostgresUserRepository(queries)
	tokenRepo := auth.NewPostgresTokenRepository(queries)
	verificationRepo := auth.NewPostgresVerificationRepository(queries)
	vaultRepo := vault.NewPostgresVaultRepository(queries)
	syncRepo := sync.NewPostgresSyncRepository(pool, queries)

	verificationSvc := auth.NewVerificationService(verificationRepo)
	authSvc := auth.NewAuthService(userRepo, tokenRepo, cfg.JwtSecretKey, 15*time.Minute, 7*24*time.Hour)
	vaultSvc := vault.NewVaultService(vaultRepo)
	syncSvc := sync.NewSyncService(syncRepo)

	logger := slog.New(tint.NewHandler(os.Stdout, &tint.Options{
		Level: slog.LevelDebug,
	}))
	logOpts := []logging.Option{logging.WithLogOnEvents(
		logging.StartCall, logging.FinishCall,
	)}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			auth.UnaryAuthInterceptor(cfg.JwtSecretKey),
			logging.UnaryServerInterceptor(interceptorLogger(logger), logOpts...),
		),
	)

	authv1.RegisterAuthServiceServer(grpcServer, auth.NewServer(authSvc, verificationSvc))
	vaultv1.RegisterVaultServiceServer(grpcServer, vault.NewServer(vaultSvc))
	syncv1.RegisterSyncServiceServer(grpcServer, sync.NewServer(syncSvc))

	healthServer := health.NewServer()
	healthpb.RegisterHealthServer(grpcServer, healthServer)
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)

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
		cfg:        cfg,
		db:         db,
		httpServer: &http.Server{Addr: ":8080", Handler: r},
		grpcServer: grpcServer,
	}
}

func (a *App) Run(ctx context.Context) error {
	grpcListener, err := net.Listen("tcp", ":50051")
	if err != nil {
		panic(fmt.Sprintf("gRPC failed to listen: %v", err))
	}

	errChan := make(chan error, 2)

	go func() {
		fmt.Printf("[HTTP] Server starting on %s\n", a.httpServer.Addr)
		if err := a.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errChan <- fmt.Errorf("HTTP server crash: %w", err)
		}
	}()

	go func() {
		fmt.Printf("[gRPC] Server starting on %s\n", grpcListener.Addr().String())
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

		if a.db != nil {
			_ = a.db.Close()
		}

		return nil
	}
}

func interceptorLogger(l *slog.Logger) logging.Logger {
	return logging.LoggerFunc(func(ctx context.Context, lvl logging.Level, msg string, fields ...any) {
		l.Log(ctx, slog.Level(lvl), msg, fields...)
	})
}
