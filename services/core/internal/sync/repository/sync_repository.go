package repository

import (
	"context"
	"database/sql"

	"github.com/yappachino-dev/ink/services/core/internal/models"
)

type SyncRepository struct {
	db *sql.DB
}

func NewSyncRepository(db *sql.DB) *SyncRepository {
	return &SyncRepository{
		db: db,
	}
}

func (r *SyncRepository) SyncData(ctx context.Context, userID int, reqNotes []models.Note, reqProjects []models.Project, clientCursor int) (int, []models.Note, []models.Project, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, nil, nil, err
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback()
		}
	}()

	currentCursor, err := r.GetUserCursorTx(ctx, tx, userID)
	if err != nil {
		return 0, nil, nil, err
	}

	hasChanges := len(reqNotes) > 0 || len(reqProjects) > 0
	newCursor := currentCursor

	if hasChanges {
		newCursor = currentCursor + 1

		if err = r.UpdateUserCursorTx(ctx, tx, userID, newCursor); err != nil {
			return 0, nil, nil, err
		}

		if err = r.UpsertProjectsTx(ctx, tx, userID, reqProjects, newCursor); err != nil {
			return 0, nil, nil, err
		}

		if err = r.UpsertNotesTx(ctx, tx, userID, reqNotes, newCursor); err != nil {
			return 0, nil, nil, err
		}

	}

	projects, err := r.GetProjectChangesTx(ctx, tx, userID, clientCursor)
	if err != nil {
		return 0, nil, nil, err
	}

	notes, err := r.GetNotesChangesTx(ctx, tx, userID, clientCursor)
	if err != nil {
		return 0, nil, nil, err
	}

	if err = tx.Commit(); err != nil {
		return 0, nil, nil, err
	}

	return newCursor, notes, projects, nil
}
