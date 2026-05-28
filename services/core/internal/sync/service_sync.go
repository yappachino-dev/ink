package sync

import (
	"context"

	"github.com/yappachino-dev/ink/services/core/internal/models"
)

type SyncPayload struct {
	ClientCursor int
	Projects     []models.Project
	Notes        []models.Note
}

type SyncResult struct {
	NextCursor int
	Projects   []models.Project
	Notes      []models.Note
}

type SyncService struct {
	repo *SyncRepository
}

func NewSyncService(repo *SyncRepository) *SyncService {
	return &SyncService{repo: repo}
}

func (s *SyncService) Sync(ctx context.Context, userID int, req SyncPayload) (SyncResult, error) {
	nextCursor, respNotes, respProjects, err := s.repo.SyncData(ctx, userID, req.ClientCursor, req.Notes, req.Projects)
	if err != nil {
		return SyncResult{}, err
	}

	return SyncResult{
		NextCursor: nextCursor,
		Notes:      respNotes,
		Projects:   respProjects,
	}, nil
}
