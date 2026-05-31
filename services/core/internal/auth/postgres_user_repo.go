package auth

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/database"
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
		return err
	}

	user.ID = int(row.ID)
	user.CreatedAt = database.PgToTime(row.CreatedAt)
	user.UpdatedAt = database.PgToTime(row.UpdatedAt)
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
		CreatedAt:    database.PgToTime(row.CreatedAt),
		UpdatedAt:    database.PgToTime(row.UpdatedAt),
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
		CreatedAt:    database.PgToTime(row.CreatedAt),
		UpdatedAt:    database.PgToTime(row.UpdatedAt),
	}, nil
}
