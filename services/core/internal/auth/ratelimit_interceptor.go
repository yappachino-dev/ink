package auth

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"net"
	"time"

	"github.com/yappachino-dev/ink/services/core/internal/ratelimit"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

// methodLimit binds each public auth RPC to a per-peer-IP fixed-window limit.
var methodLimit = map[string]*ratelimit.Limiter{
	"/auth.v1.AuthService/Login":        ratelimit.New(10, time.Minute),
	"/auth.v1.AuthService/Register":     ratelimit.New(5, time.Minute),
	"/auth.v1.AuthService/VerifyEmail":  ratelimit.New(3, time.Hour),
	"/auth.v1.AuthService/RefreshToken": ratelimit.New(30, time.Minute),
	"/auth.v1.AuthService/Logout":       ratelimit.New(10, time.Minute),
}

// verifyEmailEmailLimiter additionally caps verification codes per account
// address, so one attacker cannot bomb an arbitrary inbox from many IPs.
var verifyEmailEmailLimiter = ratelimit.New(3, time.Hour)

// UnaryRateLimitInterceptor enforces per-method rate limits on public methods.
// Authenticated methods are not limited here.
func UnaryRateLimitInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		limiter, ok := methodLimit[info.FullMethod]
		if !ok {
			return handler(ctx, req)
		}

		ipKey := peerKey(ctx)
		if !limiter.Allow(ipKey) {
			return nil, status.Errorf(codes.ResourceExhausted, "too many requests, retry later")
		}

		if info.FullMethod == "/auth.v1.AuthService/VerifyEmail" {
			if r, ok := req.(interface{ GetEmail() string }); ok && r.GetEmail() != "" {
				sum := sha256.Sum256([]byte(r.GetEmail()))
				if !verifyEmailEmailLimiter.Allow(hex.EncodeToString(sum[:])) {
					return nil, status.Error(codes.ResourceExhausted, "too many requests for this account")
				}
			}
		}

		return handler(ctx, req)
	}
}

// peerKey returns the peer's host address without the ephemeral port, so the
// fixed-window limits apply per client IP and cannot be reset by reconnecting.
func peerKey(ctx context.Context) string {
	p, ok := peer.FromContext(ctx)
	if !ok || p.Addr == nil {
		return "unknown"
	}
	if host, _, err := net.SplitHostPort(p.Addr.String()); err == nil {
		return host
	}
	return p.Addr.String()
}
