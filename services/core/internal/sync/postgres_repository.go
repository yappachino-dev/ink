package sync

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

type PostgresSyncRepository struct {
	db *pgxpool.Pool
	q  *store.Queries
}

func NewPostgresSyncRepository(db *pgxpool.Pool, q *store.Queries) *PostgresSyncRepository {
	return &PostgresSyncRepository{db: db, q: q}
}

func (r *PostgresSyncRepository) SyncData(ctx context.Context, userID int, clientCursor int, changes SyncChanges) (int, SyncChanges, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return 0, SyncChanges{}, err
	}

	defer tx.Rollback(ctx)

	qtx := r.q.WithTx(tx)

	currentCursor, err := qtx.GetUserCursor(ctx, int32(userID))
	if err != nil {
		return 0, SyncChanges{}, err
	}

	hasChanges := len(changes.Projects) > 0 || len(changes.Notes) > 0
	newCursor := int(currentCursor)

	if hasChanges {
		newCursor = newCursor + 1

		if err = qtx.UpdateUserCursor(ctx, store.UpdateUserCursorParams{
			SyncCursor: int32(newCursor),
			ID:         int32(userID),
		}); err != nil {
			return 0, SyncChanges{}, err
		}

		if err = r.UpsertProjects(ctx, qtx, userID, newCursor, changes.Projects); err != nil {
			return 0, SyncChanges{}, err
		}

		if err = r.UpsertNotes(ctx, qtx, userID, newCursor, changes.Notes); err != nil {
			return 0, SyncChanges{}, err
		}

	}

	projects, err := r.GetProjectChanges(ctx, qtx, userID, clientCursor)
	if err != nil {
		return 0, SyncChanges{}, err
	}

	notes, err := r.GetNotesChanges(ctx, qtx, userID, clientCursor)
	if err != nil {
		return 0, SyncChanges{}, err
	}

	if err = tx.Commit(ctx); err != nil {
		return 0, SyncChanges{}, err
	}

	return newCursor, SyncChanges{Projects: projects, Notes: notes}, nil
}

func timeToPg(t time.Time) pgtype.Timestamp {
	if t.IsZero() {
		return pgtype.Timestamp{Valid: false}
	}
	return pgtype.Timestamp{Time: t, Valid: true}
}

func (r *PostgresSyncRepository) UpsertProjects(ctx context.Context, qtx *store.Queries, userID int, syncSequence int, projects []Project) error {
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
			CreatedAt:        timeToPg(p.CreatedAt),
			UpdatedAt:        timeToPg(p.UpdatedAt),
			DeletedAt:        timeToPg(p.DeletedAt),
		})
	}

	batchResults := qtx.UpsertProjects(ctx, params)
	defer batchResults.Close()

	var batchErr error
	batchResults.Exec(func(index int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
}

func (r *PostgresSyncRepository) UpsertNotes(ctx context.Context, qtx *store.Queries, userID int, syncSequence int, notes []Note) error {
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
			CreatedAt:        timeToPg(n.CreatedAt),
			UpdatedAt:        timeToPg(n.UpdatedAt),
			DeletedAt:        timeToPg(n.DeletedAt),
		})
	}

	batchResults := qtx.UpsertNotes(ctx, params)
	defer batchResults.Close()

	var batchErr error
	batchResults.Exec(func(index int, err error) {
		if err != nil && batchErr == nil {
			batchErr = err
		}
	})

	return batchErr
}

func pgToTime(ts pgtype.Timestamp) time.Time {
	if !ts.Valid {
		return time.Time{}
	}
	return ts.Time
}

func (r *PostgresSyncRepository) GetProjectChanges(ctx context.Context, qtx *store.Queries, userID int, cursor int) ([]Project, error) {
	rows, err := qtx.GetProjectChanges(ctx, store.GetProjectChangesParams{
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
			CreatedAt:        pgToTime(row.CreatedAt),
			UpdatedAt:        pgToTime(row.UpdatedAt),
			DeletedAt:        pgToTime(row.DeletedAt),
		})
	}

	return projects, nil
}

func (r *PostgresSyncRepository) GetNotesChanges(ctx context.Context, qtx *store.Queries, userID int, cursor int) ([]Note, error) {
	rows, err := qtx.GetNoteChanges(ctx, store.GetNoteChangesParams{
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
			CreatedAt:        pgToTime(row.CreatedAt),
			UpdatedAt:        pgToTime(row.UpdatedAt),
			DeletedAt:        pgToTime(row.DeletedAt),
		})
	}

	return notes, nil
}
