package vault

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresVaultRepository struct {
	q *store.Queries
}

func NewPostgresVaultRepository(q *store.Queries) *PostgresVaultRepository {
	return &PostgresVaultRepository{q: q}
}

func (r *PostgresVaultRepository) GetKeySlotsByUserID(ctx context.Context, userID int) ([]KeySlot, error) {
	rows, err := r.q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		return nil, err
	}

	keySlots := make([]KeySlot, 0, len(rows))
	for _, row := range rows {
		keySlots = append(keySlots, KeySlot{
			UserID:           userID,
			Type:             int(row.KeyType),
			Salt:             row.Salt,
			WrappedMasterKey: row.WrappedMasterKey,
			UpdatedAt:        row.UpdatedAt,
		})
	}

	return keySlots, nil
}

func (r *PostgresVaultRepository) UpsertKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error {
	if len(keySlots) == 0 {
		return nil
	}

	params := make([]store.UpsertKeySlotsParams, len(keySlots))
	for i, keySlot := range keySlots {
		params[i] = store.UpsertKeySlotsParams{
			UserID:           int32(userID),
			KeyType:          int32(keySlot.Type),
			Salt:             keySlot.Salt,
			WrappedMasterKey: keySlot.WrappedMasterKey,
			UpdatedAt:        keySlot.UpdatedAt,
		}
	}

	return database.ExecBatch(r.db(ctx).UpsertKeySlots(ctx, params))
}

func (r *PostgresVaultRepository) db(ctx context.Context) *store.Queries {
	if tx, ok := appctx.TxFromContext[pgx.Tx](ctx); ok {
		return r.q.WithTx(tx)
	}
	return r.q
}
