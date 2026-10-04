package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

// Environment names accepted in APP_ENV. Development (the default) logs
// verification codes instead of sending them; production has no sender yet and refuses to start.
const (
	EnvDevelopment = "development"
	EnvProduction  = "production"
)

type Config struct {
	DatabaseURL  string
	JwtSecretKey string
	Env          string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	databaseURL := os.Getenv("DATABASE_URL")

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
	}

	return &cfg, nil
}
