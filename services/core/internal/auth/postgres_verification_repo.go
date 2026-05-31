package auth

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresVerificationRepository struct {
	q *store.Queries
}

func NewPostgresVerificationRepository(q *store.Queries) *PostgresVerificationRepository {
	return &PostgresVerificationRepository{q: q}
}

func (r *PostgresVerificationRepository) CreateEmailVerification(ctx context.Context, email string, codeHash string) error {
	return r.q.CreateEmailVerification(ctx, store.CreateEmailVerificationParams{
		Email:    email,
		CodeHash: codeHash,
	})
}

func (r *PostgresVerificationRepository) LatestByEmail(ctx context.Context, email string) (*EmailVerification, error) {
	row, err := r.q.GetLatestEmailVerification(ctx, email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &EmailVerification{
		ID:        int(row.ID),
		Email:     row.Email,
		CodeHash:  row.CodeHash,
		CreatedAt: database.PgToTime(row.CreatedAt),
		ExpiresAt: database.PgToTime(row.ExpiresAt),
		UsedAt:    database.PgToTime(row.UsedAt),
	}, nil
}

func (r *PostgresVerificationRepository) MarkAsUsed(ctx context.Context, id int) error {
	return r.q.MarkEmailVerificationAsUsed(ctx, int32(id))
}

func (r *PostgresVerificationRepository) MarkAllAsUsed(ctx context.Context, email string) error {
	return r.q.MarkAllEmailVerificationsAsUsedByEmail(ctx, email)
}
