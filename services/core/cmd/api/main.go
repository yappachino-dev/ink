package main

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	authHandler "github.com/yappachino-dev/ink/services/core/internal/auth/handler"
	authMiddleware "github.com/yappachino-dev/ink/services/core/internal/auth/middleware"
	authRepository "github.com/yappachino-dev/ink/services/core/internal/auth/repository"
	authService "github.com/yappachino-dev/ink/services/core/internal/auth/service"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"

	syncHandler "github.com/yappachino-dev/ink/services/core/internal/sync/handler"
	syncRepository "github.com/yappachino-dev/ink/services/core/internal/sync/repository"
	syncService "github.com/yappachino-dev/ink/services/core/internal/sync/service"

	vaultGRPC "github.com/yappachino-dev/ink/services/core/internal/vault/grpc"
	keyHandler "github.com/yappachino-dev/ink/services/core/internal/vault/http"
	keyRepository "github.com/yappachino-dev/ink/services/core/internal/vault/repository"
	keyService "github.com/yappachino-dev/ink/services/core/internal/vault/service"

	"github.com/gin-gonic/gin"
	"github.com/yappachino-dev/ink/services/core/internal/config"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/email"

	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging"
	"google.golang.org/grpc"
)

func main() {
	fmt.Println("Backend is running")

	cfg, err := config.Load()
	if err != nil {
		panic(fmt.Sprintf("failed to load config: %v", err))
	}

	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		panic(fmt.Sprintf("failed to connect database: %v", err))
	}

	defer func(db *sql.DB) {
		if db != nil {
			_ = db.Close()
		}
	}(db)

	fmt.Println("Connected to database")

	userRepo := authRepository.NewUserRepo(db)
	refreshTokenRepo := authRepository.NewRefreshTokenRepo(db)

	emailVerificationRepo := authRepository.NewEmailVerificationRepository(db)
	emailVerificationSvc := authService.NewEmailVerificationService(emailVerificationRepo)
	emailSender := email.NewSender(cfg.SMTP)

	authSvc := authService.NewAuthService(
		userRepo,
		refreshTokenRepo,
		cfg.JwtSecretKey,
		15*time.Minute,
		7*24*time.Hour,
	)

	authH := authHandler.NewHandler(authSvc)

	emailVerificationH := authHandler.NewEmailVerificationHandler(
		emailVerificationSvc,
		authSvc,
		emailSender,
	)

	keyRepo := keyRepository.NewKeyRepository(db)
	keySvc := keyService.NewKeyService(keyRepo)
	keyH := keyHandler.NewKeyHandler(keySvc)

	syncRepo := syncRepository.NewSyncRepository(db)
	syncSvc := syncService.NewSyncService(syncRepo)
	syncH := syncHandler.NewSyncHandler(syncSvc)

	r := gin.Default()
	setupHTTPRoutes(r, authH, emailVerificationH, keyH, syncH, cfg.JwtSecretKey)

	httpServer := http.Server{Addr: ":8080", Handler: r}

	grpcListener, err := net.Listen("tcp", ":50051")
	if err != nil {
		panic(fmt.Sprintf("gRPC failed to listen: %v", err))
	}

	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	}))

	logOpts := []logging.Option{
		logging.WithLogOnEvents(logging.StartCall, logging.FinishCall),
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			logging.UnaryServerInterceptor(interceptorLogger(logger), logOpts...),
		),
		grpc.ChainStreamInterceptor(
			logging.StreamServerInterceptor(interceptorLogger(logger), logOpts...),
		),
	)

	vaultGRPCServer := vaultGRPC.NewVaultServer(keySvc)
	vaultv1.RegisterVaultServiceServer(grpcServer, vaultGRPCServer)

	errChan := make(chan error, 2)

	go func() {
		fmt.Printf("[HTTP] Server starting on %s\n", httpServer.Addr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errChan <- fmt.Errorf("HTTP server crash: %w", err)
		}
	}()

	go func() {
		fmt.Printf("[gRPC] Server starting on %s\n", grpcListener.Addr().String())
		if err := grpcServer.Serve(grpcListener); err != nil {
			errChan <- fmt.Errorf("gRPC server crash: %w", err)
		}
	}()

	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-errChan:
		fmt.Printf("Fatal error encountered, shutting down: %v\n", err)
	case sig := <-stopChan:
		fmt.Printf("Received system signal (%v), initiating graceful shutdown...\n", sig)
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		fmt.Printf("HTTP shutdown error: %v\n", err)
	} else {
		fmt.Println("HTTP server exited cleanly.")
	}

	grpcServer.GracefulStop()
	fmt.Println("gRPC server exited cleanly.")
}

func setupHTTPRoutes(r *gin.Engine, authH *authHandler.Handler, emailH *authHandler.EmailVerificationHandler, keyH *keyHandler.KeyHandler, syncH *syncHandler.SyncHandler, jwtSecret string) {
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "active",
			"service": "Ink API",
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

	mw := authMiddleware.AuthMiddleware(jwtSecret)

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
