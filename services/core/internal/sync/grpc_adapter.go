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
		changes.Notebooks = make([]Notebook, 0, len(pbReq.Changes.Notebooks))
		for _, p := range pbReq.Changes.Notebooks {
			id, err := uuid.Parse(p.Id)
			if err != nil {
				return SyncPayload{}, fmt.Errorf("invalid notebook id %q: %w", p.Id, err)
			}

			changes.Notebooks = append(changes.Notebooks, Notebook{
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
			if n.NotebookId != nil {
				parsed, err := uuid.Parse(*n.NotebookId)
				if err != nil {
					return SyncPayload{}, fmt.Errorf("invalid notebook_id %q for note %q: %w", *n.NotebookId, n.Id, err)
				}
				pID = &parsed
			}

			changes.Notes = append(changes.Notes, Note{
				ID:               id,
				NotebookID:       pID,
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
	pbNotebooks := make([]*syncv1.Notebook, 0, len(result.Changes.Notebooks))
	for _, p := range result.Changes.Notebooks {
		pbNotebooks = append(pbNotebooks, &syncv1.Notebook{
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
		var notebookIDStr *string
		if n.NotebookID != nil {
			str := n.NotebookID.String()
			notebookIDStr = &str
		}

		pbNotes = append(pbNotes, &syncv1.Note{
			Id:               n.ID.String(),
			NotebookId:       notebookIDStr,
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
			Notebooks: pbNotebooks,
			Notes:     pbNotes,
		},
	}
}
