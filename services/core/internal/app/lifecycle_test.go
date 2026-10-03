package app

import (
	"context"
	"net"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
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

// servingApp builds an App with live listeners over an unreachable pool, so
// the only thing under test is the shutdown path.
func servingApp(t *testing.T) (*App, net.Listener, *pgxpool.Pool) {
	t.Helper()

	pool := unreachablePool(t)
	app := &App{
		pool:       pool,
		db:         stdlib.OpenDBFromPool(pool),
		httpServer: &http.Server{Handler: http.NotFoundHandler()},
		grpcServer: grpc.NewServer(),
	}

	httpListener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}

	return app, httpListener, pool
}

// A listener closed before Serve makes gRPC fail immediately, which is the
// crash arm: the signal never fires and serve still has to release resources.
func TestServeTearsDownWhenAServerFails(t *testing.T) {
	app, httpListener, pool := servingApp(t)
	t.Cleanup(func() { _ = httpListener.Close() })

	grpcListener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	if err := grpcListener.Close(); err != nil {
		t.Fatalf("close listener: %v", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err = app.serve(ctx, httpListener, grpcListener)
	if err == nil {
		t.Fatal("serve returned nil after the gRPC listener failed")
	}
	if !strings.Contains(err.Error(), "gRPC server crash") {
		t.Fatalf("unexpected error: %v", err)
	}

	pingCtx, pingCancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer pingCancel()
	if perr := pool.Ping(pingCtx); perr == nil || !strings.Contains(perr.Error(), "closed pool") {
		t.Fatalf("pool survived the crash path: %v", perr)
	}
}

func TestServeTearsDownOnSignal(t *testing.T) {
	app, httpListener, pool := servingApp(t)
	t.Cleanup(func() { _ = httpListener.Close() })

	grpcListener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- app.serve(ctx, httpListener, grpcListener) }()

	cancel()

	select {
	case err := <-done:
		if err != nil {
			t.Fatalf("serve returned %v on a clean signal", err)
		}
	case <-time.After(10 * time.Second):
		t.Fatal("serve did not return after the context was cancelled")
	}

	pingCtx, pingCancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer pingCancel()
	if perr := pool.Ping(pingCtx); perr == nil || !strings.Contains(perr.Error(), "closed pool") {
		t.Fatalf("pool survived the signal path: %v", perr)
	}
}

func TestReadinessProbeStopsOnCancel(t *testing.T) {
	pool := unreachablePool(t)
	healthServer := health.NewServer()

	ctx, cancel := context.WithCancel(context.Background())
	done := watchReadiness(ctx, stdlib.OpenDBFromPool(pool), healthServer)

	cancel()

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("readiness probe outlived its context")
	}
}
