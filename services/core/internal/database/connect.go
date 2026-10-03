package database

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// connectPingTimeout bounds a single attempt. The DSN's connect_timeout only
// bounds the dial, not the postgres startup handshake, so a server that
// accepts and then goes quiet would otherwise hang the first attempt forever
// and make the retry budget below a fiction.
const connectPingTimeout = 3 * time.Second

func pingWithTimeout(ctx context.Context, pool *pgxpool.Pool) error {
	pingCtx, cancel := context.WithTimeout(ctx, connectPingTimeout)
	defer cancel()
	return pool.Ping(pingCtx)
}

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
		if err = pingWithTimeout(ctx, pool); err == nil {
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
