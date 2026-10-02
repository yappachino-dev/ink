package sync

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresSyncRepository struct {
	q *store.Queries
}

func NewPostgresSyncRepository(q *store.Queries) *PostgresSyncRepository {
	return &PostgresSyncRepository{q: q}
}

func (r *PostgresSyncRepository) GetUserCursor(ctx context.Context, userID int) (int, error) {
	cursor, err := r.db(ctx).GetUserCursor(ctx, int32(userID))
	return int(cursor), err
}

func (r *PostgresSyncRepository) GetUserCursorForUpdate(ctx context.Context, userID int) (int, error) {
	cursor, err := r.db(ctx).GetUserCursorForUpdate(ctx, int32(userID))
	return int(cursor), err
}

func (r *PostgresSyncRepository) UpdateUserCursor(ctx context.Context, userID int, cursor int) error {
	return r.db(ctx).UpdateUserCursor(ctx, store.UpdateUserCursorParams{
		ID:         int32(userID),
		SyncCursor: int32(cursor),
	})
}

func (r *PostgresSyncRepository) GetNotebookChanges(ctx context.Context, userID int, cursor int) ([]Notebook, error) {
	rows, err := r.db(ctx).GetNotebookChanges(ctx, store.GetNotebookChangesParams{
		UserID:       int32(userID),
		SyncSequence: int32(cursor),
	})
	if err != nil {
		return nil, err
	}

	notebooks := make([]Notebook, 0, len(rows))
	for _, row := range rows {
		notebooks = append(notebooks, Notebook{
			ID:               row.ID,
			UserID:           userID,
			EncryptedContent: row.EncryptedContent,
			Version:          int(row.Version),
			SyncSequence:     int(row.SyncSequence),
			CreatedAt:        row.CreatedAt,
			UpdatedAt:        row.UpdatedAt,
			DeletedAt:        database.FromNullTime(row.DeletedAt),
		})
	}

	return notebooks, nil
}

func (r *PostgresSyncRepository) UpsertNotebooks(ctx context.Context, userID int, syncSequence int, notebooks []Notebook) error {
	if len(notebooks) == 0 {
		return nil
	}

	params := make([]store.UpsertNotebooksParams, 0, len(notebooks))
	for _, p := range notebooks {
		params = append(params, store.UpsertNotebooksParams{
			ID:               p.ID,
			UserID:           int32(userID),
			EncryptedContent: p.EncryptedContent,
			Version:          int32(p.Version),
			SyncSequence:     int32(syncSequence),
			CreatedAt:        p.CreatedAt,
			UpdatedAt:        p.UpdatedAt,
			DeletedAt:        database.ToNullTime(p.DeletedAt),
		})
	}

	return database.ExecBatch(r.db(ctx).UpsertNotebooks(ctx, params))
}

func (r *PostgresSyncRepository) GetNoteChanges(ctx context.Context, userID int, cursor int) ([]Note, error) {
	rows, err := r.db(ctx).GetNoteChanges(ctx, store.GetNoteChangesParams{
		UserID:       int32(userID),
		SyncSequence: int32(cursor),
	})
	if err != nil {
		return nil, err
	}

	notes := make([]Note, 0, len(rows))
	for _, row := range rows {

		notes = append(notes, Note{
			ID:               row.ID,
			UserID:           userID,
			NotebookID:       row.NotebookID,
			EncryptedTitle:   row.EncryptedTitle,
			EncryptedContent: row.EncryptedContent,
			Version:          int(row.Version),
			SyncSequence:     int(row.SyncSequence),
			CreatedAt:        row.CreatedAt,
			UpdatedAt:        row.UpdatedAt,
			DeletedAt:        database.FromNullTime(row.DeletedAt),
		})
	}

	return notes, nil
}

func (r *PostgresSyncRepository) UpsertNotes(ctx context.Context, userID int, syncSequence int, notes []Note) error {
	if len(notes) == 0 {
		return nil
	}

	params := make([]store.UpsertNotesParams, 0, len(notes))
	for _, n := range notes {
		params = append(params, store.UpsertNotesParams{
			ID:               n.ID,
			UserID:           int32(userID),
			NotebookID:       n.NotebookID,
			EncryptedTitle:   n.EncryptedTitle,
			EncryptedContent: n.EncryptedContent,
			Version:          int32(n.Version),
			SyncSequence:     int32(syncSequence),
			CreatedAt:        n.CreatedAt,
			UpdatedAt:        n.UpdatedAt,
			DeletedAt:        database.ToNullTime(n.DeletedAt),
		})
	}

	return database.ExecBatch(r.db(ctx).UpsertNotes(ctx, params))
}

func (r *PostgresSyncRepository) FindNotebookIDsOwnedByOtherUsers(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error) {
	if len(ids) == 0 {
		return nil, nil
	}

	return r.db(ctx).FindNotebookIDsOwnedByOtherUsers(ctx, store.FindNotebookIDsOwnedByOtherUsersParams{
		Ids:    ids,
		UserID: int32(userID),
	})
}

func (r *PostgresSyncRepository) FindNoteIDsOwnedByOtherUsers(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error) {
	if len(ids) == 0 {
		return nil, nil
	}

	return r.db(ctx).FindNoteIDsOwnedByOtherUsers(ctx, store.FindNoteIDsOwnedByOtherUsersParams{
		Ids:    ids,
		UserID: int32(userID),
	})
}

func (r *PostgresSyncRepository) FindNotebookIDsAvailableToUser(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error) {
	if len(ids) == 0 {
		return nil, nil
	}

	return r.db(ctx).FindNotebookIDsAvailableToUser(ctx, store.FindNotebookIDsAvailableToUserParams{
		Ids:    ids,
		UserID: int32(userID),
	})
}

func (r *PostgresSyncRepository) db(ctx context.Context) *store.Queries {
	if tx, ok := appctx.TxFromContext[pgx.Tx](ctx); ok {
		return r.q.WithTx(tx)
	}
	return r.q
}
