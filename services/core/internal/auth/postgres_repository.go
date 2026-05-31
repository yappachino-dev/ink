package auth

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresAuthRepository struct {
	q *store.Queries
}

func NewPostgresAuthRepository(q *store.Queries) *PostgresAuthRepository {
	return &PostgresAuthRepository{q: q}
}

// --- UserRepository Implementation ---

func (r *PostgresAuthRepository) CreateUser(ctx context.Context, user *User) error {
	row, err := r.q.CreateUser(ctx, store.CreateUserParams{
		Email:        user.Email,
		PasswordHash: user.PasswordHash,
	})
	if err != nil {
		return err
	}

	user.ID = int(row.ID)
	user.CreatedAt = database.PgToTime(row.CreatedAt)
	user.UpdatedAt = database.PgToTime(row.UpdatedAt)
	return nil
}

func (r *PostgresAuthRepository) GetUserByEmail(ctx context.Context, email string) (*User, error) {
	row, err := r.q.GetUserByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &User{
		ID:           int(row.ID),
		Email:        row.Email,
		PasswordHash: row.PasswordHash,
		SyncCursor:   int(row.SyncCursor),
		CreatedAt:    database.PgToTime(row.CreatedAt),
		UpdatedAt:    database.PgToTime(row.UpdatedAt),
	}, nil
}

func (r *PostgresAuthRepository) GetUserByID(ctx context.Context, id int) (*User, error) {
	row, err := r.q.GetUserByID(ctx, int32(id))
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &User{
		ID:           int(row.ID),
		Email:        row.Email,
		PasswordHash: row.PasswordHash,
		SyncCursor:   int(row.SyncCursor),
		CreatedAt:    database.PgToTime(row.CreatedAt),
		UpdatedAt:    database.PgToTime(row.UpdatedAt),
	}, nil
}

// --- RefreshTokenRepository Implementation ---

func (r *PostgresAuthRepository) CreateRefreshToken(ctx context.Context, token *RefreshToken) error {
	row, err := r.q.CreateRefreshToken(ctx, store.CreateRefreshTokenParams{
		UserID:    int32(token.UserID),
		TokenHash: token.TokenHash,
		ExpiresAt: database.TimeToPg(token.ExpiresAt),
	})
	if err != nil {
		return err
	}

	token.ID = int(row.ID)
	token.CreatedAt = database.PgToTime(row.CreatedAt)
	token.RevokedAt = database.PgToTime(row.RevokedAt)
	return nil
}

func (r *PostgresAuthRepository) GetRefreshTokenByHash(ctx context.Context, hash string) (*RefreshToken, error) {
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
		TokenHash: row.TokenHash,
		ExpiresAt: database.PgToTime(row.ExpiresAt),
		CreatedAt: database.PgToTime(row.CreatedAt),
		RevokedAt: database.PgToTime(row.RevokedAt),
	}, nil
}

func (r *PostgresAuthRepository) RevokeRefreshTokenByHash(ctx context.Context, hash string) error {
	return r.q.RevokeRefreshTokenByHash(ctx, store.RevokeRefreshTokenByHashParams{
		TokenHash: hash,
		RevokedAt: database.TimeToPg(time.Now().UTC()),
	})
}

func (r *PostgresAuthRepository) RevokeAllRefreshTokensByUserID(ctx context.Context, userID int) error {
	return r.q.RevokeAllRefreshTokensByUserID(ctx, int32(userID))
}

func (r *PostgresAuthRepository) UpdateRefreshToken(ctx context.Context, token *RefreshToken) error {
	return r.q.UpdateRefreshToken(ctx, store.UpdateRefreshTokenParams{
		ID:        int32(token.ID),
		TokenHash: token.TokenHash,
		ExpiresAt: database.TimeToPg(token.ExpiresAt),
		RevokedAt: database.TimeToPg(token.RevokedAt),
	})
}

// --- EmailVerificationRepository Implementation ---

func (r *PostgresAuthRepository) CreateEmailVerification(ctx context.Context, email string, codeHash string) error {
	return r.q.CreateEmailVerification(ctx, store.CreateEmailVerificationParams{
		Email:    email,
		CodeHash: codeHash,
	})
}

func (r *PostgresAuthRepository) GetLatestEmailVerification(ctx context.Context, email string) (*EmailVerification, error) {
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

func (r *PostgresAuthRepository) MarkEmailVerificationAsUsed(ctx context.Context, id int) error {
	return r.q.MarkEmailVerificationAsUsed(ctx, int32(id))
}

func (r *PostgresAuthRepository) MarkAllEmailVerificationsAsUsedByEmail(ctx context.Context, email string) error {
	return r.q.MarkAllEmailVerificationsAsUsedByEmail(ctx, email)
}
