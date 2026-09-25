package sync

import (
	"fmt"
	"time"

	"github.com/google/uuid"
	syncv1 "github.com/yappachino-dev/ink/gen/go/pb/sync/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func pbToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

func toDomain(pbReq *syncv1.SyncRequest) (SyncPayload, error) {
	if pbReq == nil {
		return SyncPayload{}, nil
	}

	changes := SyncChanges{}

	if pbReq.Changes != nil {
		changes.Projects = make([]Project, 0, len(pbReq.Changes.Projects))
		for _, p := range pbReq.Changes.Projects {
			id, err := uuid.Parse(p.Id)
			if err != nil {
				return SyncPayload{}, fmt.Errorf("invalid project id %q: %w", p.Id, err)
			}

			changes.Projects = append(changes.Projects, Project{
				ID:               id,
				EncryptedContent: p.EncryptedContent,
				Version:          int(p.Version),
				CreatedAt:        pbToTime(p.CreatedAt),
				UpdatedAt:        pbToTime(p.UpdatedAt),
				DeletedAt:        pbToTime(p.DeletedAt),
			})
		}

		changes.Notes = make([]Note, 0, len(pbReq.Changes.Notes))
		for _, n := range pbReq.Changes.Notes {
			id, err := uuid.Parse(n.Id)
			if err != nil {
				return SyncPayload{}, fmt.Errorf("invalid note id %q: %w", n.Id, err)
			}

			var pID *uuid.UUID
			if n.ProjectId != nil {
				parsed, err := uuid.Parse(*n.ProjectId)
				if err != nil {
					return SyncPayload{}, fmt.Errorf("invalid project_id %q for note %q: %w", *n.ProjectId, n.Id, err)
				}
				pID = &parsed
			}

			changes.Notes = append(changes.Notes, Note{
				ID:               id,
				ProjectID:        pID,
				EncryptedTitle:   n.EncryptedTitle,
				EncryptedContent: n.EncryptedContent,
				Version:          int(n.Version),
				CreatedAt:        pbToTime(n.CreatedAt),
				UpdatedAt:        pbToTime(n.UpdatedAt),
				DeletedAt:        pbToTime(n.DeletedAt),
			})
		}
	}

	payload := SyncPayload{
		ClientCursor: int(pbReq.Cursor),
		Changes:      changes,
	}

	return payload, nil
}

func timeToPb(t time.Time) *timestamppb.Timestamp {
	if t.IsZero() {
		return nil
	}
	return timestamppb.New(t)
}

func toProto(result SyncResult) *syncv1.SyncResponse {
	pbProjects := make([]*syncv1.Project, 0, len(result.Changes.Projects))
	for _, p := range result.Changes.Projects {
		pbProjects = append(pbProjects, &syncv1.Project{
			Id:               p.ID.String(),
			EncryptedContent: p.EncryptedContent,
			Version:          int32(p.Version),
			CreatedAt:        timeToPb(p.CreatedAt),
			UpdatedAt:        timeToPb(p.UpdatedAt),
			DeletedAt:        timeToPb(p.DeletedAt),
		})
	}

	pbNotes := make([]*syncv1.Note, 0, len(result.Changes.Notes))
	for _, n := range result.Changes.Notes {
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
			CreatedAt:        timeToPb(n.CreatedAt),
			UpdatedAt:        timeToPb(n.UpdatedAt),
			DeletedAt:        timeToPb(n.DeletedAt),
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
