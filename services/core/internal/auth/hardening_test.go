package auth

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	authv1 "github.com/yappachino-dev/ink/gen/go/pb/auth/v1"
)

// A token signed with a different HMAC variant is still a valid signature over
// the same secret, so accepting the whole family means a downgrade to a weaker
// algorithm is one flag away. Only HS256 is ever issued.
func TestUnaryAuthInterceptor_RejectsOtherHMACAlgorithms(t *testing.T) {
	interceptor := UnaryAuthInterceptor(interceptorSecret)

	claims := AccessTokenClaims{
		UserID: 1,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
		},
	}

	for _, tc := range []struct {
		name   string
		method jwt.SigningMethod
	}{
		{"hs384", jwt.SigningMethodHS384},
		{"hs512", jwt.SigningMethodHS512},
	} {
		t.Run(tc.name, func(t *testing.T) {
			raw, err := jwt.NewWithClaims(tc.method, claims).SignedString([]byte(interceptorSecret))
			if err != nil {
				t.Fatalf("sign: %v", err)
			}

			called := false
			info := &grpc.UnaryServerInfo{FullMethod: "/sync.v1.SyncService/Sync"}
			_, err = interceptor(bearerCtx(raw), nil, info, handler(t, &called))

			if called {
				t.Fatalf("handler must not run for a %s token", tc.name)
			}
			if status.Code(err) != codes.Unauthenticated {
				t.Fatalf("want Unauthenticated, got %v", err)
			}
		})
	}
}

