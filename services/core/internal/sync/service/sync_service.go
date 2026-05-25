package service

import (
	"context"

	"github.com/mad-yappachino/ink/services/core/internal/dto"
	"github.com/mad-yappachino/ink/services/core/internal/models"
	"github.com/mad-yappachino/ink/services/core/internal/sync/repository"
	"github.com/google/uuid"
)

type SyncService struct {
	repo *repository.SyncRepository
}

func NewSyncService(repo *repository.SyncRepository) *SyncService {
	return &SyncService{repo: repo}
}

func (s *SyncService) Sync(ctx context.Context, userID int, req dto.SyncRequest) (dto.SyncResponse, error) {
	var reqNotes []models.Note
	for _, n := range req.Changes.Notes {
		id, _ := uuid.Parse(n.ID)
		var pID *uuid.UUID
		if n.ProjectID != nil {
			parsed, _ := uuid.Parse(*n.ProjectID)
			pID = &parsed
		}
		reqNotes = append(reqNotes, models.Note{
			ID:               id,
			ProjectID:        pID,
			EncryptedTitle:   n.EncryptedTitle,
			EncryptedContent: n.EncryptedContent,
			Version:          n.Version,
			CreatedAt:        n.CreatedAt,
			UpdatedAt:        n.UpdatedAt,
			DeletedAt:        n.DeletedAt,
		})
	}

	var reqProjects []models.Project
	for _, p := range req.Changes.Projects {
		id, _ := uuid.Parse(p.ID)
		reqProjects = append(reqProjects, models.Project{
			ID:               id,
			EncryptedContent: p.EncryptedContent,
			Version:          p.Version,
			CreatedAt:        p.CreatedAt,
			UpdatedAt:        p.UpdatedAt,
			DeletedAt:        p.DeletedAt,
		})
	}

	nextCursor, respNotes, respProjects, err := s.repo.SyncData(ctx, userID, reqNotes, reqProjects, req.Cursor)
	if err != nil {
		return dto.SyncResponse{}, err
	}

	var dtoNotes []dto.NoteSyncDTO
	for _, n := range respNotes {
		var pID *string
		if n.ProjectID != nil {
			str := n.ProjectID.String()
			pID = &str
		}
		dtoNotes = append(dtoNotes, dto.NoteSyncDTO{
			ID:               n.ID.String(),
			ProjectID:        pID,
			EncryptedTitle:   n.EncryptedTitle,
			EncryptedContent: n.EncryptedContent,
			Version:          n.Version,
			CreatedAt:        n.CreatedAt,
			UpdatedAt:        n.UpdatedAt,
			DeletedAt:        n.DeletedAt,
		})
	}

	var dtoProjects []dto.ProjectSyncDTO
	for _, p := range respProjects {
		dtoProjects = append(dtoProjects, dto.ProjectSyncDTO{
			ID:               p.ID.String(),
			EncryptedContent: p.EncryptedContent,
			Version:          p.Version,
			CreatedAt:        p.CreatedAt,
			UpdatedAt:        p.UpdatedAt,
			DeletedAt:        p.DeletedAt,
		})
	}

	if dtoNotes == nil {
		dtoNotes = []dto.NoteSyncDTO{}
	}
	if dtoProjects == nil {
		dtoProjects = []dto.ProjectSyncDTO{}
	}

	return dto.SyncResponse{
		NextCursor: nextCursor,
		Changes: dto.SyncChanges{
			Notes:    dtoNotes,
			Projects: dtoProjects,
		},
	}, nil
}
