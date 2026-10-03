package auth

import (
	"context"
	"fmt"

	"github.com/golang-jwt/jwt/v5"
	grpcmiddlewareauth "github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/auth"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type contextKey string

const UserIDKey contextKey = "user_id"

func UnaryAuthInterceptor(secret string) grpc.UnaryServerInterceptor {
	standard := grpcmiddlewareauth.UnaryServerInterceptor(func(ctx context.Context) (context.Context, error) {
		return authenticate(ctx, secret)
	})

	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		// The middleware AuthFunc does not receive the method name, so public
		// route policy stays in this small outer interceptor wrapper.
		if isPublicMethod(info.FullMethod) {
			return handler(ctx, req)
		}
		return standard(ctx, req, info, handler)
	}
}

func authenticate(ctx context.Context, secret string) (context.Context, error) {
	rawToken, err := grpcmiddlewareauth.AuthFromMD(ctx, "Bearer")
	if err != nil {
		return nil, err
	}

	var claims AccessTokenClaims
	token, err := jwt.ParseWithClaims(rawToken, &claims, func(token *jwt.Token) (any, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return nil, status.Error(codes.Unauthenticated, "provided authorization token is invalid")
	}

	return appctx.WithUserID(ctx, claims.UserID), nil
}

func isPublicMethod(method string) bool {
	publicMethods := map[string]bool{
		"/auth.v1.AuthService/Login":        true,
		"/auth.v1.AuthService/Register":     true,
		"/auth.v1.AuthService/VerifyEmail":  true,
		"/auth.v1.AuthService/RefreshToken": true,

		"/grpc.health.v1.Health/Check": true,
		"/grpc.health.v1.Health/Watch": true,
	}
	return publicMethods[method]
}
