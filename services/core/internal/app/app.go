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
	"github.com/yappachino-dev/ink/services/core/internal/auth"
	"github.com/yappachino-dev/ink/services/core/internal/config"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/email"
	"github.com/yappachino-dev/ink/services/core/internal/vault"
	authv1 "github.com/yappachino-dev/ink/services/gen/pb/auth/v1"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/grpc"

	syncHandler "github.com/yappachino-dev/ink/services/core/internal/sync/handler"
	syncRepository "github.com/yappachino-dev/ink/services/core/internal/sync/repository"
	syncService "github.com/yappachino-dev/ink/services/core/internal/sync/service"
)

type App struct {
	cfg        *config.Config
	db         *sql.DB
	httpServer *http.Server
	grpcServer *grpc.Server
}

func New(cfg *config.Config) *App {
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		panic(fmt.Sprintf("failed to connect database: %v", err))
	}

	userRepo := auth.NewUserRepo(db)
	refreshTokenRepo := auth.NewRefreshTokenRepo(db)
	emailVerificationRepo := auth.NewEmailVerificationRepository(db)
	keyRepo := vault.NewKeyRepository(db)
	syncRepo := syncRepository.NewSyncRepository(db)

	emailVerificationSvc := auth.NewEmailVerificationService(emailVerificationRepo)
	authSvc := auth.NewAuthService(userRepo, refreshTokenRepo, cfg.JwtSecretKey, 15*time.Minute, 7*24*time.Hour)
	emailSender := email.NewSender(cfg.SMTP)
	keySvc := vault.NewKeyService(keyRepo)
	syncSvc := syncService.NewSyncService(syncRepo)

	authH := auth.NewHandler(authSvc)
	emailVerificationH := auth.NewEmailVerificationHandler(
		emailVerificationSvc,
		authSvc,
		emailSender,
	)
	keyH := vault.NewKeyHandler(keySvc)
	syncH := syncHandler.NewSyncHandler(syncSvc)

	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	}))
	logOpts := []logging.Option{
		logging.WithLogOnEvents(logging.StartCall, logging.FinishCall),
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			auth.UnaryAuthInterceptor(cfg.JwtSecretKey),
			logging.UnaryServerInterceptor(interceptorLogger(logger), logOpts...),
		),
	)

	authv1.RegisterAuthServiceServer(grpcServer, auth.NewServer(authSvc, emailVerificationSvc))
	vaultv1.RegisterVaultServiceServer(grpcServer, vault.NewServer(keySvc))

	r := gin.Default()
	setupHTTPRoutes(r, authH, emailVerificationH, keyH, syncH, cfg.JwtSecretKey)

	return &App{
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

func setupHTTPRoutes(
	r *gin.Engine,
	authH *auth.Handler,
	emailH *auth.EmailVerificationHandler,
	keyH *vault.KeyHandler,
	syncH *syncHandler.SyncHandler,
	jwtSecret string,
) {
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "active",
			"service": "Ink API Backbone",
		})
	})

	v1 := r.Group("/api/v1")

	authGroup := v1.Group("/auth")
	{
		authGroup.POST("/login", authH.Login)
		authGroup.POST("/refresh", authH.Refresh)
		authGroup.POST("/logout", authH.Logout)
		authGroup.POST("/verify-email", emailH.VerifyEmail)
		authGroup.POST("/confirm-register", emailH.ConfirmRegister)
	}

	mw := auth.AuthMiddleware(jwtSecret)
	protected := v1.Group("/protected").Use(mw)
	{
		protected.GET("/me", func(c *gin.Context) {
			userID, _ := c.Get("user_id")
			c.JSON(http.StatusOK, gin.H{
				"user_id": userID,
			})
		})

		protected.GET("/me/keys", keyH.GetKeySlots)
		protected.POST("/me/keys", keyH.SaveKeySlots)
		protected.PATCH("/me/keys", keyH.SaveKeySlots)
		protected.POST("/sync", syncH.Sync)
	}
}

func interceptorLogger(l *slog.Logger) logging.Logger {
	return logging.LoggerFunc(func(ctx context.Context, lvl logging.Level, msg string, fields ...any) {
		l.Log(ctx, slog.Level(lvl), msg, fields...)
	})
}
