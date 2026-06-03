package sync

import (
	"context"
)

type Transactor interface {
	WithinTransaction(ctx context.Context, fn func(txCtx context.Context) error) error
}

type SyncRepository interface {
	GetUserCursor(ctx context.Context, userID int) (int, error)
	UpdateUserCursor(ctx context.Context, userID int, cursor int) error
	UpsertProjects(ctx context.Context, userID int, syncSequence int, projects []Project) error
	UpsertNotes(ctx context.Context, userID int, syncSequence int, notes []Note) error
	GetProjectChanges(ctx context.Context, userID int, cursor int) ([]Project, error)
	GetNoteChanges(ctx context.Context, userID int, cursor int) ([]Note, error)
}

type SyncService struct {
	transactor Transactor
	repo       SyncRepository
}

func NewSyncService(transactor Transactor, repo SyncRepository) *SyncService {
	return &SyncService{transactor: transactor, repo: repo}
}

func (s *SyncService) Sync(ctx context.Context, userID int, req SyncPayload) (SyncResult, error) {
	var newCursor int
	var fetchedChanges SyncChanges

	err := s.transactor.WithinTransaction(ctx, func(txCtx context.Context) error {
		currentCursor, err := s.repo.GetUserCursor(txCtx, userID)
		if err != nil {
			return err
		}

		hasChanges := len(req.Changes.Projects) > 0 || len(req.Changes.Notes) > 0
		newCursor = currentCursor
		if hasChanges {
			newCursor = newCursor + 1

			if err = s.repo.UpdateUserCursor(txCtx, userID, newCursor); err != nil {
				return err
			}

			if err = s.repo.UpsertProjects(txCtx, userID, newCursor, req.Changes.Projects); err != nil {
				return err
			}

			if err = s.repo.UpsertNotes(txCtx, userID, newCursor, req.Changes.Notes); err != nil {
				return err
			}
		}

		projects, err := s.repo.GetProjectChanges(txCtx, userID, req.ClientCursor)
		if err != nil {
			return err
		}

		notes, err := s.repo.GetNoteChanges(txCtx, userID, req.ClientCursor)
		if err != nil {
			return err
		}

		fetchedChanges = SyncChanges{Projects: projects, Notes: notes}

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
