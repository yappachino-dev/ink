package auth

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresTokenRepository struct {
	q *store.Queries
}

func NewPostgresTokenRepository(q *store.Queries) *PostgresTokenRepository {
	return &PostgresTokenRepository{q: q}
}

func (r *PostgresTokenRepository) Create(ctx context.Context, token *RefreshToken) error {
	row, err := r.q.CreateRefreshToken(ctx, store.CreateRefreshTokenParams{
		UserID:    int32(token.UserID),
		Hash:      token.Hash,
		ExpiresAt: token.ExpiresAt,
	})
	if err != nil {
		return err
	}

	token.ID = int(row.ID)
	token.CreatedAt = row.CreatedAt
	token.RevokedAt = database.FromNullTime(row.RevokedAt)
	return nil
}

func (r *PostgresTokenRepository) ByHash(ctx context.Context, hash []byte) (*RefreshToken, error) {
	row, err := r.q.GetRefreshTokenByHash(ctx, hash)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &RefreshToken{
		ID:        int(row.ID),
		UserID:    int(row.UserID),
		Hash:      row.Hash,
		ExpiresAt: row.ExpiresAt,
		CreatedAt: row.CreatedAt,
		RevokedAt: database.FromNullTime(row.RevokedAt),
	}, nil
}

func (r *PostgresTokenRepository) RevokeByHash(ctx context.Context, hash []byte) error {
	return r.q.RevokeRefreshTokenByHash(ctx, store.RevokeRefreshTokenByHashParams{
		Hash:      hash,
		RevokedAt: database.ToNullTime(time.Now().UTC()),
	})
}

func (r *PostgresTokenRepository) RevokeAllByUserID(ctx context.Context, userID int) error {
	return r.q.RevokeAllRefreshTokensByUserID(ctx, int32(userID))
}

func (r *PostgresTokenRepository) Update(ctx context.Context, token *RefreshToken) error {
	return r.q.UpdateRefreshToken(ctx, store.UpdateRefreshTokenParams{
		ID:        int32(token.ID),
		Hash:      token.Hash,
		ExpiresAt: token.ExpiresAt,
		RevokedAt: database.ToNullTime(token.RevokedAt),
	})
}
