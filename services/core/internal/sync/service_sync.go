package sync

import (
	"context"
)

type SyncRepository interface {
	SyncData(ctx context.Context, userID int, clientCursor int, changes SyncChanges) (int, SyncChanges, error)
}

type SyncService struct {
	repo SyncRepository
}

func NewSyncService(repo SyncRepository) *SyncService {
	return &SyncService{repo: repo}
}

func (s *SyncService) Sync(ctx context.Context, userID int, req SyncPayload) (SyncResult, error) {
	nextCursor, changes, err := s.repo.SyncData(ctx, userID, req.ClientCursor, req.Changes)
	if err != nil {
		return SyncResult{}, err
	}

	return SyncResult{
		NextCursor: nextCursor,
		Changes:    changes,
	}, nil
}
