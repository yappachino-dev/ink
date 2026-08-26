package auth

import (
	"context"
	"net"
	"testing"
	"time"

	"github.com/yappachino-dev/ink/services/core/internal/ratelimit"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

func peerContext(ctx context.Context, ip string, port int) context.Context {
	return peer.NewContext(ctx, &peer.Peer{
		Addr: &net.TCPAddr{IP: net.ParseIP(ip), Port: port},
	})
}

func TestPeerKey_StripsEphemeralPort(t *testing.T) {
	got := peerKey(peerContext(context.Background(), "203.0.113.7", 54321))
	if want := "203.0.113.7"; got != want {
		t.Fatalf("peerKey = %q, want %q", got, want)
	}
}

// Connections from the same IP but different ephemeral ports must share one
// fixed-window budget — otherwise limits could be reset by reconnecting.
func TestRateLimit_SameIPAcrossConnectionsSharesBudget(t *testing.T) {
	l := ratelimit.New(2, time.Minute)

	call := func(ip string, port int) error {
		if !l.Allow(peerKey(peerContext(context.Background(), ip, port))) {
			return status.Error(codes.ResourceExhausted, "too many requests")
		}
		return nil
	}

	if err := call("198.51.100.1", 1111); err != nil {
		t.Fatalf("first call from port 1111 must pass: %v", err)
	}
	if err := call("198.51.100.1", 2222); err != nil {
		t.Fatalf("second call from port 2222 must share the same IP budget: %v", err)
	}
	if err := call("198.51.100.1", 3333); status.Code(err) != codes.ResourceExhausted {
		t.Fatalf("third call must be limited, got %v", err)
	}
	if err := call("198.51.100.2", 4444); err != nil {
		t.Fatalf("other IP must be unaffected: %v", err)
	}
}
