// Package dbtest provides a throwaway Postgres for integration tests.
package dbtest

import (
	"context"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/testcontainers/testcontainers-go/modules/postgres"

	"github.com/yappachino-dev/ink/services/core/internal/database"
)

// StartPostgres boots an ephemeral Postgres container, applies all embedded
// migrations, and returns a connected pool. The container is terminated on
// test cleanup. Requires Docker; tests using it fail (not skip) without one.
func StartPostgres(t *testing.T) *pgxpool.Pool {
	t.Helper()

	ctx := context.Background()
	ctr, err := postgres.Run(ctx,
		"postgres:18-alpine",
		postgres.WithDatabase("data"),
		postgres.WithUsername("postgres"),
		postgres.WithPassword("postgres"),
		postgres.BasicWaitStrategies(),
	)
	if err != nil {
		t.Fatalf("start postgres container: %v", err)
	}
	t.Cleanup(func() {
		_ = ctr.Terminate(ctx)
	})

	dsn, err := ctr.ConnectionString(ctx)
	if err != nil {
		t.Fatalf("connection string: %v", err)
	}

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Fatalf("connect pool: %v", err)
	}
	t.Cleanup(pool.Close)

	connCfg, err := pgx.ParseConfig(dsn)
	if err != nil {
		t.Fatalf("parse conn config: %v", err)
	}
	sqlDB := stdlib.OpenDB(*connCfg)
	defer sqlDB.Close()
	if err := database.Migrate(ctx, sqlDB); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}

	return pool
}
