package database

import (
	"context"
	"errors"
	"fmt"
	"net"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// blackhole accepts TCP and never speaks the postgres protocol, which is the
// case connect_timeout in the DSN does not cover: it bounds the dial only.
//
// Accepted connections are collected under a mutex and closed from the test's
// own cleanup. Registering cleanup from the accept loop would race test
// completion and panic once the test function has already returned.
func blackhole(t *testing.T) string {
	t.Helper()

	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}

	var (
		mu    sync.Mutex
		conns []net.Conn
	)

	t.Cleanup(func() {
		_ = ln.Close()
		mu.Lock()
		defer mu.Unlock()
		for _, c := range conns {
			_ = c.Close()
		}
	})

	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			mu.Lock()
			conns = append(conns, conn)
			mu.Unlock()
		}
	}()

	return fmt.Sprintf("postgres://u:p@%s/db?sslmode=disable", ln.Addr().String())
}

func TestPingWithTimeoutGivesUpOnASilentServer(t *testing.T) {
	pool, err := pgxpool.New(context.Background(), blackhole(t))
	if err != nil {
		t.Fatalf("new pool: %v", err)
	}
	defer pool.Close()

	start := time.Now()
	// Background, not the signal context: nothing but connectPingTimeout can
	// end this call.
	err = pingWithTimeout(context.Background(), pool)
	elapsed := time.Since(start)

	if err == nil {
		t.Fatal("ping succeeded against a server that never replied")
	}
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("expected a deadline, got %v", err)
	}
	if elapsed > connectPingTimeout+2*time.Second {
		t.Fatalf("ping took %v, past the %v bound", elapsed, connectPingTimeout)
	}
}
