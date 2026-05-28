package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DatabaseURL  string
	JwtSecretKey string
	SMTP         SMTP
}

type SMTP struct {
	Host     string
	Port     string
	User     string
	Password string
	From     string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	databaseURL := os.Getenv("DATABASE_URL")

	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")
	smtpUser := os.Getenv("SMTP_USER")
	smtpPassword := os.Getenv("SMTP_PASSWORD")
	smtpFrom := os.Getenv("SMTP_FROM")

	jwtSecretKey := os.Getenv("JWT_SECRET_KEY")

	if databaseURL == "" {
		return nil, fmt.Errorf("missing required database environment variables")
	}

	cfg := Config{
		DatabaseURL:  databaseURL,
		JwtSecretKey: jwtSecretKey,
		SMTP: SMTP{
			Host:     smtpHost,
			Port:     smtpPort,
			User:     smtpUser,
			Password: smtpPassword,
			From:     smtpFrom,
		},
	}

	return &cfg, nil
}
