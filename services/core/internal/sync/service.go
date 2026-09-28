package sync

import (
	"context"

	"github.com/google/uuid"
	"github.com/yappachino-dev/ink/services/core/internal/database"
)

type SyncRepository interface {
	GetUserCursor(ctx context.Context, userID int) (int, error)
	GetUserCursorForUpdate(ctx context.Context, userID int) (int, error)
	UpdateUserCursor(ctx context.Context, userID int, cursor int) error
	UpsertNotebooks(ctx context.Context, userID int, syncSequence int, notebooks []Notebook) error
	UpsertNotes(ctx context.Context, userID int, syncSequence int, notes []Note) error
	GetNotebookChanges(ctx context.Context, userID int, cursor int) ([]Notebook, error)
	GetNoteChanges(ctx context.Context, userID int, cursor int) ([]Note, error)
	FindNotebookIDsOwnedByOtherUsers(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error)
	FindNoteIDsOwnedByOtherUsers(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error)
	FindNotebookIDsAvailableToUser(ctx context.Context, ids []uuid.UUID, userID int) ([]uuid.UUID, error)
}

type SyncService struct {
	transactor database.Transactor
	repo       SyncRepository
}

func NewSyncService(transactor database.Transactor, repo SyncRepository) *SyncService {
	return &SyncService{transactor: transactor, repo: repo}
}

func (s *SyncService) Sync(ctx context.Context, userID int, req SyncPayload) (SyncResult, error) {
	var newCursor int
	var fetchedChanges SyncChanges
	hasChanges := len(req.Changes.Notebooks) > 0 || len(req.Changes.Notes) > 0

	err := s.transactor.WithinTransaction(ctx, func(txCtx context.Context) error {
		var currentCursor int
		var err error
		if hasChanges {
			// Only push transactions need to serialize cursor allocation.
			currentCursor, err = s.repo.GetUserCursorForUpdate(txCtx, userID)
		} else {
			currentCursor, err = s.repo.GetUserCursor(txCtx, userID)
		}
		if err != nil {
			return err
		}

		newCursor = currentCursor
		if hasChanges {
			// Reject the whole batch before the cursor moves: a partial push
			// would leave the client's cursor and the stored rows disagreeing.
			if err = validateChanges(txCtx, userID, req.Changes, s.repo); err != nil {
				return err
			}

			newCursor = newCursor + 1

			if err = s.repo.UpdateUserCursor(txCtx, userID, newCursor); err != nil {
				return err
			}

			if err = s.repo.UpsertNotebooks(txCtx, userID, newCursor, req.Changes.Notebooks); err != nil {
				return err
			}

			if err = s.repo.UpsertNotes(txCtx, userID, newCursor, req.Changes.Notes); err != nil {
				return err
			}
		}

		notebooks, err := s.repo.GetNotebookChanges(txCtx, userID, req.ClientCursor)
		if err != nil {
			return err
		}

		notes, err := s.repo.GetNoteChanges(txCtx, userID, req.ClientCursor)
		if err != nil {
			return err
		}

		fetchedChanges = SyncChanges{Notebooks: notebooks, Notes: notes}

		return nil
	})
	if err != nil {
		return SyncResult{}, err
	}

	return SyncResult{
		NextCursor: newCursor,
		Changes:    fetchedChanges,
	}, nil
}
