package appctx

import "context"

type contextKey string

const userIDKey contextKey = "user_id"

func WithUserID(ctx context.Context, usedID int) context.Context {
	return context.WithValue(ctx, userIDKey, usedID)
}

func UserIDFromContext(ctx context.Context) (int, bool) {
	userID, ok := ctx.Value(userIDKey).(int)
	return userID, ok
}
