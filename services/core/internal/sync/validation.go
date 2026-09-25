package sync

import (
	"context"

	"github.com/google/uuid"
)

// findDuplicateIDs returns the IDs that occur more than once in ids, preserving
// first-seen order and reporting each duplicated id exactly once.
func findDuplicateIDs(ids []uuid.UUID) []uuid.UUID {
	seen := make(map[uuid.UUID]struct{}, len(ids))
	reported := make(map[uuid.UUID]struct{}, len(ids))
	var duplicates []uuid.UUID

	for _, id := range ids {
		if _, ok := seen[id]; ok {
			if _, already := reported[id]; !already {
				reported[id] = struct{}{}
				duplicates = append(duplicates, id)
			}
			continue
		}
		seen[id] = struct{}{}
	}

	return duplicates
}

func projectIDs(projects []Project) []uuid.UUID {
	ids := make([]uuid.UUID, 0, len(projects))
	for _, p := range projects {
		ids = append(ids, p.ID)
	}

	return ids
}

func noteIDs(notes []Note) []uuid.UUID {
	ids := make([]uuid.UUID, 0, len(notes))
	for _, n := range notes {
		ids = append(ids, n.ID)
	}

	return ids
}

// referencedProjectIDs returns the distinct, non-nil project references carried
// by a batch of notes.
func referencedProjectIDs(notes []Note) []uuid.UUID {
	seen := make(map[uuid.UUID]struct{}, len(notes))
	var ids []uuid.UUID

	for _, n := range notes {
		if n.ProjectID == nil {
			continue
		}
		if _, ok := seen[*n.ProjectID]; ok {
			continue
		}
		seen[*n.ProjectID] = struct{}{}
		ids = append(ids, *n.ProjectID)
	}

	return ids
}

// missingFrom returns the elements of want that are absent from have.
func missingFrom(want, have []uuid.UUID) []uuid.UUID {
	present := make(map[uuid.UUID]struct{}, len(have))
	for _, id := range have {
		present[id] = struct{}{}
	}

	var missing []uuid.UUID
	for _, id := range want {
		if _, ok := present[id]; ok {
			continue
		}
		missing = append(missing, id)
	}

	return missing
}

// validateChanges rejects a push batch before any row is written. Every check
// is fatal for the whole batch: a partially applied push would leave the
// client's cursor and the server's rows disagreeing.
func validateChanges(ctx context.Context, userID int, changes SyncChanges, repo SyncRepository) error {
	// 1. Duplicates are rejected outright. They are decided from the request
	//    alone, so they cost no round trip.
	if dups := findDuplicateIDs(projectIDs(changes.Projects)); len(dups) > 0 {
		return &DuplicateEntityIDsError{Entity: "project", IDs: dups}
	}
	if dups := findDuplicateIDs(noteIDs(changes.Notes)); len(dups) > 0 {
		return &DuplicateEntityIDsError{Entity: "note", IDs: dups}
	}

	// 2. A pushed ID owned by another account must fail loudly instead of
	//    being swallowed by the `WHERE user_id = EXCLUDED.user_id` upsert guard.
	pushedProjects := projectIDs(changes.Projects)
	if len(pushedProjects) > 0 {
		foreign, err := repo.FindProjectIDsOwnedByOtherUsers(ctx, pushedProjects, userID)
		if err != nil {
			return err
		}
		if len(foreign) > 0 {
			return &OwnershipConflictError{Entity: "project", IDs: foreign}
		}
	}

	pushedNotes := noteIDs(changes.Notes)
	if len(pushedNotes) > 0 {
		foreign, err := repo.FindNoteIDsOwnedByOtherUsers(ctx, pushedNotes, userID)
		if err != nil {
			return err
		}
		if len(foreign) > 0 {
			return &OwnershipConflictError{Entity: "note", IDs: foreign}
		}
	}

	// 3. Notes may only reference projects this account owns. The schema's
	//    foreign key checks `projects.id` alone, so ownership is not implied.
	//
	//    Projects carried by this same batch count as available: they have
	//    already cleared the ownership check in step 2 and are about to be
	//    written. Without this, the core offline workflow — creating a project
	//    and a note that references it while disconnected, then pushing both at
	//    once — would be rejected, because the project does not exist in the
	//    database yet at validation time.
	references := referencedProjectIDs(changes.Notes)
	if len(references) > 0 {
		inBatch := make(map[uuid.UUID]struct{}, len(changes.Projects))
		for _, p := range changes.Projects {
			inBatch[p.ID] = struct{}{}
		}

		external := make([]uuid.UUID, 0, len(references))
		for _, ref := range references {
			if _, ok := inBatch[ref]; !ok {
				external = append(external, ref)
			}
		}

		// Skips the round trip entirely when every reference ships in this batch.
		if len(external) > 0 {
			available, err := repo.FindProjectIDsAvailableToUser(ctx, external, userID)
			if err != nil {
				return err
			}
			if unavailable := missingFrom(external, available); len(unavailable) > 0 {
				return &ProjectReferenceError{IDs: unavailable}
			}
		}
	}

	return nil
}
