package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

// Environment names accepted in APP_ENV. Development (the default) logs
// verification codes instead of emailing them; production sends real email.
const (
	EnvDevelopment = "development"
	EnvProduction  = "production"
)

type Config struct {
	DatabaseURL  string
	JwtSecretKey string
	Env          string
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

	env := os.Getenv("APP_ENV")
	if env == "" {
		env = EnvDevelopment
	}
	if env != EnvDevelopment && env != EnvProduction {
		return nil, fmt.Errorf("invalid APP_ENV %q: expected %q or %q", env, EnvDevelopment, EnvProduction)
	}

	if databaseURL == "" {
		return nil, fmt.Errorf("missing required database environment variables")
	}

	if jwtSecretKey == "" {
		return nil, fmt.Errorf("missing required JWT_SECRET_KEY")
	}

	cfg := Config{
		DatabaseURL:  databaseURL,
		JwtSecretKey: jwtSecretKey,
		Env:          env,
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
