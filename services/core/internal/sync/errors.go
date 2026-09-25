package sync

import (
	"fmt"
	"strings"

	"github.com/google/uuid"
)

// DuplicateEntityIDsError reports a push batch that carries the same entity ID
// more than once. Accepting it would let the last row of the batch silently
// win while the client advances its cursor as if every row had landed.
type DuplicateEntityIDsError struct {
	Entity string
	IDs    []uuid.UUID
}

func (e *DuplicateEntityIDsError) Error() string {
	return fmt.Sprintf("sync batch contains duplicate %s ids: %s", e.Entity, formatUUIDs(e.IDs))
}

// OwnershipConflictError reports a pushed entity ID that already belongs to a
// different account. The upsert guards on user_id turn this into a silent
// no-op, so it has to be detected explicitly or the client would believe its
// write was synced when nothing was stored.
type OwnershipConflictError struct {
	Entity string
	IDs    []uuid.UUID
}

func (e *OwnershipConflictError) Error() string {
	return fmt.Sprintf("%s ids already belong to another account: %s", e.Entity, formatUUIDs(e.IDs))
}

// ProjectReferenceError reports notes that reference projects the pushing
// account cannot use. Missing and foreign-owned projects are deliberately
// reported identically so the error cannot be used to probe which project IDs
// exist in the system.
type ProjectReferenceError struct {
	IDs []uuid.UUID
}

func (e *ProjectReferenceError) Error() string {
	return fmt.Sprintf("notes reference projects that are not available to this account: %s", formatUUIDs(e.IDs))
}

// maxReportedIDs bounds how many ids an error message spells out. A malformed
// or hostile batch can carry thousands of them, and the message travels back to
// the client and into every log line that records the rejection.
const maxReportedIDs = 5

func formatUUIDs(ids []uuid.UUID) string {
	limit := len(ids)
	if limit > maxReportedIDs {
		limit = maxReportedIDs
	}

	parts := make([]string, 0, limit+1)
	for _, id := range ids[:limit] {
		parts = append(parts, id.String())
	}

	if remaining := len(ids) - limit; remaining > 0 {
		parts = append(parts, fmt.Sprintf("(and %d more)", remaining))
	}

	return strings.Join(parts, ", ")
}
