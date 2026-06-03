package appctx

import "context"

type (
	userIDKey struct{}
	txKey     struct{}
)

func WithUserID(ctx context.Context, usedID int) context.Context {
	return context.WithValue(ctx, userIDKey{}, usedID)
}

func UserIDFromContext(ctx context.Context) (int, bool) {
	userID, ok := ctx.Value(userIDKey{}).(int)
	return userID, ok
}

func WithTx(ctx context.Context, tx any) context.Context {
	return context.WithValue(ctx, txKey{}, tx)
}

func TxFromContext[T any](ctx context.Context) (T, bool) {
	tx, ok := ctx.Value(txKey{}).(T)
	return tx, ok
}
