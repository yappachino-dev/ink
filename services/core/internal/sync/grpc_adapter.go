package sync

import (
	"time"

	"github.com/google/uuid"
	"github.com/yappachino-dev/ink/services/core/internal/models"
	syncv1 "github.com/yappachino-dev/ink/services/gen/pb/sync/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func ProtoToDomain(pbReq *syncv1.SyncRequest) SyncPayload {
	if pbReq == nil {
		return SyncPayload{}
	}

	payload := SyncPayload{
		ClientCursor: int(pbReq.Cursor),
	}

	if pbReq.Changes != nil {
		for _, p := range pbReq.Changes.Projects {
			id, _ := uuid.Parse(p.Id)
			var deletedAt *time.Time
			if p.DeletedAt != nil {
				t := p.DeletedAt.AsTime()
				deletedAt = &t
			}
			payload.Projects = append(payload.Projects, models.Project{
				ID:               id,
				EncryptedContent: p.EncryptedContent,
				Version:          int(p.Version),
				CreatedAt:        p.CreatedAt.AsTime(),
				UpdatedAt:        p.UpdatedAt.AsTime(),
				DeletedAt:        deletedAt,
			})
		}

		for _, n := range pbReq.Changes.Notes {
			id, _ := uuid.Parse(n.Id)

			var pID *uuid.UUID
			if n.ProjectId != nil {
				parsed, _ := uuid.Parse(*n.ProjectId)
				pID = &parsed
			}

			var deletedAt *time.Time
			if n.DeletedAt != nil {
				t := n.DeletedAt.AsTime()
				deletedAt = &t
			}

			payload.Notes = append(payload.Notes, models.Note{
				ID:               id,
				ProjectID:        pID,
				EncryptedTitle:   n.EncryptedTitle,
				EncryptedContent: n.EncryptedContent,
				Version:          int(n.Version),
				CreatedAt:        n.CreatedAt.AsTime(),
				UpdatedAt:        n.UpdatedAt.AsTime(),
				DeletedAt:        deletedAt,
			})
		}
	}

	return payload
}

func DomainToProto(result SyncResult) *syncv1.SyncResponse {
	var pbProjects []*syncv1.Project
	for _, p := range result.Projects {
		var pbDeletedAt *timestamppb.Timestamp
		if p.DeletedAt != nil {
			pbDeletedAt = timestamppb.New(*p.DeletedAt)
		}

		pbProjects = append(pbProjects, &syncv1.Project{
			Id:               p.ID.String(),
			EncryptedContent: p.EncryptedContent,
			Version:          int32(p.Version),
			CreatedAt:        timestamppb.New(p.CreatedAt),
			UpdatedAt:        timestamppb.New(p.UpdatedAt),
			DeletedAt:        pbDeletedAt,
		})
	}

	var pbNotes []*syncv1.Note
	for _, n := range result.Notes {
		var pbDeletedAt *timestamppb.Timestamp
		if n.DeletedAt != nil {
			pbDeletedAt = timestamppb.New(*n.DeletedAt)
		}

		var projectIDStr *string
		if n.ProjectID != nil {
			str := n.ProjectID.String()
			projectIDStr = &str
		}

		pbNotes = append(pbNotes, &syncv1.Note{
			Id:               n.ID.String(),
			ProjectId:        projectIDStr,
			EncryptedTitle:   n.EncryptedTitle,
			EncryptedContent: n.EncryptedContent,
			Version:          int32(n.Version),
			CreatedAt:        timestamppb.New(n.CreatedAt),
			UpdatedAt:        timestamppb.New(n.UpdatedAt),
			DeletedAt:        pbDeletedAt,
		})
	}

	return &syncv1.SyncResponse{
		NextCursor: int32(result.NextCursor),
		Changes: &syncv1.SyncChanges{
			Projects: pbProjects,
			Notes:    pbNotes,
		},
	}
}
