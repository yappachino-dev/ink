package database

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
)

// Transactor abstracts running a function inside a database transaction.
// Implementations inject the transaction into the context so repositories can
// pick it up via appctx.TxFromContext.
type Transactor interface {
	WithinTransaction(ctx context.Context, fn func(txCtx context.Context) error) error
}

type PgTransactor struct {
	db *pgxpool.Pool
}

func NewPgTransactor(db *pgxpool.Pool) *PgTransactor {
	return &PgTransactor{db: db}
}

func (t *PgTransactor) WithinTransaction(ctx context.Context, fn func(ctx context.Context) error) (err error) {
	tx, err := t.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx failed: %w", err)
	}

	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback(ctx)
			panic(p)
		} else if err != nil {
			if rbErr := tx.Rollback(ctx); rbErr != nil {
				err = fmt.Errorf("tx err: %v, rollback err: %w", err, rbErr)
			}
		}
	}()

	txCtx := appctx.WithTx(ctx, tx)

	err = fn(txCtx)
	if err != nil {
		return err
	}

	err = tx.Commit(ctx)
	if err != nil {
		return fmt.Errorf("cannot commit transaction: %w", err)
	}

	return nil
}
