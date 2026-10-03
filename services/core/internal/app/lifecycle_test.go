package app

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
)

// unreachablePool builds a pool pointed at a port nothing listens on. pgx
// connects lazily, so this needs no database and no Docker: it is enough to
// observe whether the pool was closed.
func unreachablePool(t *testing.T) *pgxpool.Pool {
	t.Helper()

	cfg, err := pgxpool.ParseConfig("postgres://u:p@127.0.0.1:1/db")
	if err != nil {
		t.Fatalf("parse config: %v", err)
	}
	cfg.MinConns = 0
	cfg.MaxConns = 2

	pool, err := pgxpool.NewWithConfig(context.Background(), cfg)
	if err != nil {
		t.Fatalf("new pool: %v", err)
	}
	return pool
}

func TestShutdownClosesPoolAndDB(t *testing.T) {
	pool := unreachablePool(t)
	app := &App{pool: pool, db: stdlib.OpenDBFromPool(pool)}

	app.shutdown()

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	err := pool.Ping(ctx)
	if err == nil || !strings.Contains(err.Error(), "closed pool") {
		t.Fatalf("pool still usable after shutdown: %v", err)
	}
	if err := app.db.PingContext(ctx); err == nil {
		t.Fatal("db still usable after shutdown")
	}
}
