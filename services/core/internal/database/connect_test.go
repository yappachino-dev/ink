package database

import (
	"context"
	"errors"
	"fmt"
	"net"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// blackhole accepts TCP and never speaks the postgres protocol, which is the
// case connect_timeout in the DSN does not cover: it bounds the dial only.
func blackhole(t *testing.T) string {
	t.Helper()

	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	t.Cleanup(func() { _ = ln.Close() })

	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			t.Cleanup(func() { _ = conn.Close() })
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
