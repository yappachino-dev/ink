package database

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse database url: %w", err)
	}

	config.MaxConns = 10
	config.MinConns = 5
	config.MaxConnLifetime = 30 * time.Minute

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("failed to create pool configuration: %w", err)
	}

	maxRetries := 5
	backoffDelay := 1 * time.Second

	for attempt := 1; attempt <= maxRetries; attempt++ {
		if err = pool.Ping(ctx); err == nil {
			return pool, nil
		}

		if attempt == maxRetries {
			break
		}

		slog.Warn("database not ready, retrying", "attempt", attempt, "maxAttempts", maxRetries, "error", err, "backoff", backoffDelay)

		select {
		case <-ctx.Done():
			pool.Close()
			return nil, ctx.Err()
		case <-time.After(backoffDelay):
			backoffDelay *= 2
		}
	}

	pool.Close()
	return nil, fmt.Errorf("failed to ping database after %d attempts: %w", maxRetries, err)
}
