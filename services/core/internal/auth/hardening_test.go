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

// Login must not return faster for an unknown account than for a known one, or
// response time answers "is this email registered".
func TestLoginSpendsTheHashCostForUnknownAccounts(t *testing.T) {
	userRepo := newFakeUserRepo()
	svc := newTestService(userRepo, newFakeTokenRepo())

	if _, _, err := svc.Register(context.Background(), "user@example.com", testPassword); err != nil {
		t.Fatalf("seed user: %v", err)
	}

	measure := func(email string) time.Duration {
		start := time.Now()
		_, _, err := svc.Login(context.Background(), email, "wrong-password")
		if !errors.Is(err, ErrInvalidCredentials) {
			t.Fatalf("Login(%q) err=%v", email, err)
		}
		return time.Since(start)
	}

	measure("user@example.com") // warm both branches before comparing

	known := measure("user@example.com")
	unknown := measure("nobody@example.com")

	// bcrypt dominates both paths, so a skipped hash shows as a large ratio.
	// The bound is loose because CI is noisy; it only has to catch a path that
	// returned before the hash ran.
	if unknown < known/2 {
		t.Fatalf("unknown account took %v against %v for a known one, which leaks existence", unknown, known)
	}
}

func TestRegisterRejectsMalformedEmails(t *testing.T) {
	svc := newTestService(newFakeUserRepo(), newFakeTokenRepo())

	for _, email := range []string{
		"",
		"a@b",
		"a b@c.com",
		"Bob <a@b.com>",
		"a@@b.com",
		"@b.com",
		"a@",
		"a@b..com",
		"a@.com",
		"a@b.com\nX-Injected: 1",
	} {
		t.Run(email, func(t *testing.T) {
			if _, _, err := svc.Register(context.Background(), email, testPassword); !errors.Is(err, ErrInvalidEmail) {
				t.Fatalf("Register(%q) err=%v, want ErrInvalidEmail", email, err)
			}
		})
	}
}

// The guard is only worth something if real addresses still get through.
func TestRegisterAcceptsRealEmails(t *testing.T) {
	svc := newTestService(newFakeUserRepo(), newFakeTokenRepo())

	for _, email := range []string{"a@b.com", "first.last+tag@sub.example.co.uk"} {
		if _, _, err := svc.Register(context.Background(), email, testPassword); err != nil {
			t.Fatalf("Register(%q): %v", email, err)
		}
	}
}

func TestRegister_MalformedEmailIsInvalidArgument(t *testing.T) {
	srv, _ := newRegisterTestServer(t)

	_, err := srv.Register(context.Background(), &authv1.RegisterRequest{
		Email:    "a@b",
		Code:     "123456",
		Password: testPassword,
	})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("code=%v, want InvalidArgument (err=%v)", status.Code(err), err)
	}
}
