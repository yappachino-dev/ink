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
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
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

// Background context, not a signal one: nothing cancels it, which is exactly
// the crash path. Only shutdown can end the probe.
func TestShutdownStopsTheReadinessProbe(t *testing.T) {
	pool := unreachablePool(t)
	healthServer := health.NewServer()

	app := &App{pool: pool, db: stdlib.OpenDBFromPool(pool)}
	app.cancelReadiness, app.readinessDone = watchReadiness(app.db, healthServer)

	stopped := make(chan struct{})
	go func() { app.shutdown(); close(stopped) }()

	select {
	case <-app.readinessDone:
	case <-time.After(5 * time.Second):
		t.Fatal("shutdown did not stop the readiness probe")
	}

	select {
	case <-stopped:
	case <-time.After(5 * time.Second):
		t.Fatal("shutdown blocked after stopping the probe")
	}
}

// The status has to exist before the first tick, otherwise a probe in that
// window reads the readiness service as unknown.
func TestReadinessStatusIsSetImmediately(t *testing.T) {
	pool := unreachablePool(t)
	healthServer := health.NewServer()

	cancel, done := watchReadiness(stdlib.OpenDBFromPool(pool), healthServer)
	defer func() { cancel(); <-done }()

	resp, err := healthServer.Check(context.Background(), &healthpb.HealthCheckRequest{
		Service: readinessService,
	})
	if err != nil {
		t.Fatalf("health check: %v", err)
	}
	if resp.Status == healthpb.HealthCheckResponse_SERVICE_UNKNOWN {
		t.Fatal("readiness status unknown before the first tick")
	}
}

// GracefulStop waits for in-flight RPCs. Without escalating after the bound,
// a handler that ignores the graceful signal pins the process open forever.
func TestShutdownEscalatesWhenAnRPCNeverReturns(t *testing.T) {
	prev := shutdownTimeout
	shutdownTimeout = 200 * time.Millisecond
	t.Cleanup(func() { shutdownTimeout = prev })

	// entered is per-run: a package-level channel stays closed after the first
	// -count=2 iteration, so the wait below returns before the handler of this
	// run ever starts.
	entered := make(chan struct{})
	server := grpc.NewServer()
	server.RegisterService(&grpc.ServiceDesc{
		ServiceName: "test.Blocking",
		HandlerType: (*any)(nil),
		Methods: []grpc.MethodDesc{{
			MethodName: "Hang",
			Handler: func(_ any, ctx context.Context, _ func(any) error, _ grpc.UnaryServerInterceptor) (any, error) {
				close(entered)
				<-ctx.Done()
				return nil, ctx.Err()
			},
		}},
	}, struct{}{})

	pool := unreachablePool(t)
	app := &App{pool: pool, db: stdlib.OpenDBFromPool(pool), grpcServer: server}

	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	go func() { _ = server.Serve(listener) }()
	t.Cleanup(func() { _ = listener.Close() })

	conn, err := grpc.NewClient(listener.Addr().String(),
		grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	t.Cleanup(func() { _ = conn.Close() })

	go func() { _ = conn.Invoke(context.Background(), "/test.Blocking/Hang", nil, nil) }()

	select {
	case <-entered:
	case <-time.After(10 * time.Second):
		t.Fatal("handler never started, so nothing would block GracefulStop")
	}

	done := make(chan struct{})
	start := time.Now()
	go func() { app.shutdown(); close(done) }()

	select {
	case <-done:
	case <-time.After(4 * shutdownTimeout):
		t.Fatal("shutdown never returned: GracefulStop did not escalate")
	}

	// Bounded from below as well as above: an instant return would mean
	// GracefulStop saw no in-flight RPC, which is the race that made this test
	// able to pass without ever escalating.
	elapsed := time.Since(start)
	if elapsed < shutdownTimeout/2 {
		t.Fatalf("shutdown returned in %v, before the %v bound: nothing was escalated", elapsed, shutdownTimeout)
	}
	if elapsed > 2*shutdownTimeout {
		t.Fatalf("shutdown took %v, past the %v escalation bound", elapsed, shutdownTimeout)
	}

	pingCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if perr := pool.Ping(pingCtx); perr == nil || !strings.Contains(perr.Error(), "closed pool") {
		t.Fatalf("pool not released after escalating: %v", perr)
	}
}
