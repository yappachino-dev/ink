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

func (r *PostgresSyncRepository) UpdateUserCursor(ctx context.Context, userID int, cursor int) error {
	return r.db(ctx).UpdateUserCursor(ctx, store.UpdateUserCursorParams{
		ID:         int32(userID),
		SyncCursor: int32(cursor),
	})
}

func (r *PostgresSyncRepository) GetProjectChanges(ctx context.Context, userID int, cursor int) ([]Project, error) {
	rows, err := r.db(ctx).GetProjectChanges(ctx, store.GetProjectChangesParams{
		UserID:       int32(userID),
		SyncSequence: int32(cursor),
	})
	if err != nil {
		return nil, err
	}

	projects := make([]Project, 0, len(rows))
	for _, row := range rows {
		projects = append(projects, Project{
			ID:               row.ID,
			UserID:           userID,
			EncryptedContent: row.EncryptedContent,
			Version:          int(row.Version),
			SyncSequence:     int(row.SyncSequence),
			CreatedAt:        database.PgToTime(row.CreatedAt),
			UpdatedAt:        database.PgToTime(row.UpdatedAt),
			DeletedAt:        database.PgToTime(row.DeletedAt),
		})
	}

	return projects, nil
}

func (r *PostgresSyncRepository) UpsertProjects(ctx context.Context, userID int, syncSequence int, projects []Project) error {
	if len(projects) == 0 {
		return nil
	}

	params := make([]store.UpsertProjectsParams, 0, len(projects))
	for _, p := range projects {
		params = append(params, store.UpsertProjectsParams{
			ID:               p.ID,
			UserID:           int32(userID),
			EncryptedContent: p.EncryptedContent,
			Version:          int32(p.Version),
			SyncSequence:     int32(syncSequence),
			CreatedAt:        database.TimeToPg(p.CreatedAt),
			UpdatedAt:        database.TimeToPg(p.UpdatedAt),
			DeletedAt:        database.TimeToPg(p.DeletedAt),
		})
	}

	batchResults := r.db(ctx).UpsertProjects(ctx, params)
	defer batchResults.Close()

	var batchErr error
	batchResults.Exec(func(index int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
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
		var pID uuid.UUID
		if row.ProjectID != nil {
			pID = *row.ProjectID
		}

		notes = append(notes, Note{
			ID:               row.ID,
			UserID:           userID,
			ProjectID:        pID,
			EncryptedTitle:   row.EncryptedTitle,
			EncryptedContent: row.EncryptedContent,
			Version:          int(row.Version),
			SyncSequence:     int(row.SyncSequence),
			CreatedAt:        database.PgToTime(row.CreatedAt),
			UpdatedAt:        database.PgToTime(row.UpdatedAt),
			DeletedAt:        database.PgToTime(row.DeletedAt),
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
		var pID *uuid.UUID
		if n.ProjectID != uuid.Nil {
			pID = &n.ProjectID
		}

		params = append(params, store.UpsertNotesParams{
			ID:               n.ID,
			UserID:           int32(userID),
			ProjectID:        pID,
			EncryptedTitle:   n.EncryptedTitle,
			EncryptedContent: n.EncryptedContent,
			Version:          int32(n.Version),
			SyncSequence:     int32(syncSequence),
			CreatedAt:        database.TimeToPg(n.CreatedAt),
			UpdatedAt:        database.TimeToPg(n.UpdatedAt),
			DeletedAt:        database.TimeToPg(n.DeletedAt),
		})
	}

	batchResults := r.db(ctx).UpsertNotes(ctx, params)
	defer batchResults.Close()

	var batchErr error
	batchResults.Exec(func(index int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
}

func (r *PostgresSyncRepository) db(ctx context.Context) *store.Queries {
	if tx, ok := appctx.TxFromContext[pgx.Tx](ctx); ok {
		return r.q.WithTx(tx)
	}
	return r.q
}
