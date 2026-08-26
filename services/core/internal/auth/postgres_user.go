package auth

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresUserRepository struct {
	q *store.Queries
}

func NewPostgresUserRepository(q *store.Queries) *PostgresUserRepository {
	return &PostgresUserRepository{q: q}
}

func (r *PostgresUserRepository) Create(ctx context.Context, user *User) error {
	row, err := r.q.CreateUser(ctx, store.CreateUserParams{
		Email:        user.Email,
		PasswordHash: user.PasswordHash,
	})
	if err != nil {
		// The ByEmail pre-check in the service is racy; the UNIQUE constraint
		// is authoritative. Surface the race as a domain error instead of 500.
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return ErrUserAlreadyExists
		}
		return err
	}

	user.ID = int(row.ID)
	user.CreatedAt = row.CreatedAt
	user.UpdatedAt = row.UpdatedAt
	return nil
}

func (r *PostgresUserRepository) ByEmail(ctx context.Context, email string) (*User, error) {
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
		CreatedAt:    row.CreatedAt,
		UpdatedAt:    row.UpdatedAt,
	}, nil
}

func (r *PostgresUserRepository) ByID(ctx context.Context, id int) (*User, error) {
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
		CreatedAt:    row.CreatedAt,
		UpdatedAt:    row.UpdatedAt,
	}, nil
}
