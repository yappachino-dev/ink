package vault

import (
	"context"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresKeyRepository struct {
	q *store.Queries
}

func NewPostgresKeyRepository(q *store.Queries) *PostgresKeyRepository {
	return &PostgresKeyRepository{q: q}
}

func (r *PostgresKeyRepository) GetByUserID(ctx context.Context, userID int) ([]KeySlot, error) {
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
			UpdatedAt:        row.UpdatedAt.Time,
		})
	}

	return keySlots, nil
}

func (r *PostgresKeyRepository) Upsert(ctx context.Context, userID int, key KeySlot) error {
	return r.q.UpsertKeySlot(ctx, store.UpsertKeySlotParams{
		UserID:           int32(userID),
		KeyType:          int32(key.Type),
		Salt:             key.Salt,
		WrappedMasterKey: key.WrappedMasterKey,
		UpdatedAt:        pgtype.Timestamp{Time: key.UpdatedAt, Valid: true},
	})
}

func (r *PostgresKeyRepository) UpsertMany(ctx context.Context, userID int, keySlots []KeySlot) error {
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
			UpdatedAt:        pgtype.Timestamp{Time: keySlot.UpdatedAt, Valid: true},
		}
	}

	batchResults := r.q.UpsertKeySlots(ctx, params)
	defer batchResults.Close()

	var batchErr error
	batchResults.Exec(func(index int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
}
