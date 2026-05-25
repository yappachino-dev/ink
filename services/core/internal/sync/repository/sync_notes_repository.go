package repository

import (
	"context"
	"database/sql"

	"github.com/yappachino-dev/ink/services/core/internal/models"
)

func (r *SyncRepository) UpsertNotesTx(ctx context.Context, tx *sql.Tx, userID int, notes []models.Note, syncSequence int) error {
	for _, note := range notes {
		_, err := tx.ExecContext(
			ctx,
			`INSERT INTO notes (id, user_id, project_id, encrypted_title, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at)
			 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			 ON CONFLICT (id) DO UPDATE SET
				project_id = EXCLUDED.project_id,
				encrypted_title = EXCLUDED.encrypted_title,
				encrypted_content = EXCLUDED.encrypted_content,
				version = EXCLUDED.version,
				sync_sequence = EXCLUDED.sync_sequence,
				updated_at = EXCLUDED.updated_at,
				deleted_at = EXCLUDED.deleted_at`,
			note.ID,
			userID,
			note.ProjectID,
			note.EncryptedTitle,
			note.EncryptedContent,
			note.Version,
			syncSequence,
			note.CreatedAt,
			note.UpdatedAt,
			note.DeletedAt,
		)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *SyncRepository) GetNotesChangesTx(ctx context.Context, tx *sql.Tx, userID int, cursor int) ([]models.Note, error) {
	rows, err := tx.QueryContext(
		ctx,
		`SELECT id, project_id, encrypted_title, encrypted_content, version, sync_sequence, created_at, updated_at, deleted_at
		FROM notes WHERE user_id = $1 AND sync_sequence > $2`,
		userID, cursor,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notes []models.Note
	for rows.Next() {
		var note models.Note

		err := rows.Scan(
			&note.ID,
			&note.ProjectID,
			&note.EncryptedTitle,
			&note.EncryptedContent,
			&note.Version,
			&note.SyncSequence,
			&note.CreatedAt,
			&note.UpdatedAt,
			&note.DeletedAt,
		)
		if err != nil {
			return nil, err
		}

		notes = append(notes, note)
	}

	return notes, nil
}
