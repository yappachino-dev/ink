package auth

import (
	"context"
	"strings"

	"github.com/golang-jwt/jwt/v5"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type contextKey string

const UserIDKey contextKey = "user_id"

func UnaryAuthInterceptor(secret string) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		if isPublicMethod(info.FullMethod) {
			return handler(ctx, req)
		}

		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "missing metadata context")
		}

		values := md.Get("authorization")
		if len(values) == 0 {
			return nil, status.Error(codes.Unauthenticated, "authorization token ommited")
		}

		parts := strings.Split(values[0], " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return nil, status.Error(codes.Unauthenticated, "invalid authorization token format")
		}

		var claims AccessTokenClaims
		token, err := jwt.ParseWithClaims(parts[1], &claims, func(token *jwt.Token) (any, error) {
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			return nil, status.Error(codes.Unauthenticated, "provided authorization token is invalid")
		}

		return handler(appctx.WithUserID(ctx, claims.UserID), req)
	}
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
