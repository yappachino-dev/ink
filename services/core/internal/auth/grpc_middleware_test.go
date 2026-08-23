package auth

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

func bearerCtx(token string) context.Context {
	md := metadata.Pairs("authorization", "Bearer "+token)
	return metadata.NewIncomingContext(context.Background(), md)
}

func handler(t *testing.T, called *bool) grpc.UnaryHandler {
	t.Helper()
	return func(ctx context.Context, _ any) (any, error) {
		*called = true
		if id, ok := appctx.UserIDFromContext(ctx); ok {
			return id, nil
		}
		return 0, nil
	}
}

const interceptorSecret = "interceptor-secret"

func TestUnaryAuthInterceptor_ValidTokenPassesUserID(t *testing.T) {
	interceptor := UnaryAuthInterceptor(interceptorSecret)
	token, err := generateAccessToken(7, interceptorSecret, time.Minute)
	if err != nil {
		t.Fatalf("generateAccessToken: %v", err)
	}

	called := false
	info := &grpc.UnaryServerInfo{FullMethod: "/sync.v1.SyncService/Sync"}
	res, err := interceptor(bearerCtx(token), nil, info, handler(t, &called))

	if !called {
		t.Fatal("handler should be called")
	}
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if id, ok := res.(int); !ok || id != 7 {
		t.Fatalf("want userID 7 propagated, got %v", res)
	}
}

// Regression test for T-04: tokens declaring a non-HMAC algorithm must be
// rejected regardless of signature validity.
func TestUnaryAuthInterceptor_RejectsNonHMACAlgorithm(t *testing.T) {
	interceptor := UnaryAuthInterceptor(interceptorSecret)

	claims := AccessTokenClaims{
		UserID: 1,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
		},
	}
	// "none" algorithm — must never pass.
	token, err := jwt.NewWithClaims(jwt.SigningMethodNone, claims).SignedString(jwt.UnsafeAllowNoneSignatureType)
	if err != nil {
		t.Fatalf("craft none-token: %v", err)
	}

	called := false
	info := &grpc.UnaryServerInfo{FullMethod: "/sync.v1.SyncService/Sync"}
	_, err = interceptor(bearerCtx(token), nil, info, handler(t, &called))

	if called {
		t.Fatal("handler must not be called for none-algorithm token")
	}
	if status.Code(err) != codes.Unauthenticated {
		t.Fatalf("want Unauthenticated, got %v", err)
	}
}

func TestUnaryAuthInterceptor_GarbageAndMissingTokensRejected(t *testing.T) {
	interceptor := UnaryAuthInterceptor(interceptorSecret)
	info := &grpc.UnaryServerInfo{FullMethod: "/sync.v1.SyncService/Sync"}

	cases := []struct {
		name string
		ctx  context.Context
	}{
		{"no metadata", context.Background()},
		{"missing header", metadata.NewIncomingContext(context.Background(), metadata.Pairs("x", "y"))},
		{"malformed header", bearerCtx("not-a-jwt")},
		{"wrong scheme", metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Basic abc"))},
		{"expired token", bearerCtx(mustToken(t, -time.Minute))},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			called := false
			_, err := interceptor(tc.ctx, nil, info, handler(t, &called))
			if called {
				t.Fatal("handler must not be called")
			}
			if status.Code(err) != codes.Unauthenticated {
				t.Fatalf("want Unauthenticated, got %v", err)
			}
		})
	}
}

func mustToken(t *testing.T, ttl time.Duration) string {
	t.Helper()
	tok, err := generateAccessToken(1, interceptorSecret, ttl)
	if err != nil {
		t.Fatalf("generateAccessToken: %v", err)
	}
	return tok
}

func TestUnaryAuthInterceptor_PublicMethodsBypass(t *testing.T) {
	interceptor := UnaryAuthInterceptor(interceptorSecret)

	public := []string{
		"/auth.v1.AuthService/Login",
		"/auth.v1.AuthService/Register",
		"/auth.v1.AuthService/VerifyEmail",
		"/auth.v1.AuthService/RefreshToken",
		"/grpc.health.v1.Health/Check",
	}

	for _, m := range public {
		t.Run(fmt.Sprintf("bypass_%s", m), func(t *testing.T) {
			called := false
			info := &grpc.UnaryServerInfo{FullMethod: m}
			if _, err := interceptor(context.Background(), nil, info, handler(t, &called)); err != nil {
				t.Fatalf("public method should bypass auth: %v", err)
			}
			if !called {
				t.Fatal("handler should be called without credentials")
			}
		})
	}
}
