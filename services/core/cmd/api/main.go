package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"

	authHandler "github.com/mad-yappachino/ink/services/core/internal/auth/handler"
	authMiddleware "github.com/mad-yappachino/ink/services/core/internal/auth/middleware"
	authRepository "github.com/mad-yappachino/ink/services/core/internal/auth/repository"
	authService "github.com/mad-yappachino/ink/services/core/internal/auth/service"

	syncHandler "github.com/mad-yappachino/ink/services/core/internal/sync/handler"
	syncRepository "github.com/mad-yappachino/ink/services/core/internal/sync/repository"
	syncService "github.com/mad-yappachino/ink/services/core/internal/sync/service"

	keyHandler "github.com/mad-yappachino/ink/services/core/internal/user/handler"
	keyRepository "github.com/mad-yappachino/ink/services/core/internal/user/repository"
	keyService "github.com/mad-yappachino/ink/services/core/internal/user/service"

	"github.com/mad-yappachino/ink/services/core/internal/config"
	"github.com/mad-yappachino/ink/services/core/internal/database"
	"github.com/mad-yappachino/ink/services/core/internal/email"
	"github.com/gin-gonic/gin"
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

	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "active",
			"service": "Ink API",
		})
	})

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

	v1 := r.Group("/api/v1")
	{
		authGroup := v1.Group("/auth")
		authHandler.RegisterRoutes(authGroup, authH)
		authGroup.POST("/verify-email", emailVerificationH.VerifyEmail)
		authGroup.POST("/confirm-register", emailVerificationH.ConfirmRegister)
	}

	mw := authMiddleware.AuthMiddleware(cfg.JwtSecretKey)

	protected := v1.Group("/protected")
	protected.Use(mw)

	protected.GET("/me", func(c *gin.Context) {
		userID, _ := c.Get("user_id")

		c.JSON(http.StatusOK, gin.H{
			"user_id": userID,
		})
	})

	protected.GET("/me/keys", keyH.GetKeys)
	protected.POST("/me/keys", keyH.SaveKeys)
	protected.PATCH("/me/keys", keyH.SaveKeys)

	protected.POST("/sync", syncH.Sync)

	port := ":8080"
	fmt.Printf("Starting server on %s\n", port)
	if err := r.Run(port); err != nil {
		panic(fmt.Sprintf("failed to start server: %v", err))
	}
}
