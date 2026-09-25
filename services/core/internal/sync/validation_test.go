package sync

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
)

func TestSync_RejectsDuplicateProjectIDs(t *testing.T) {
	dup := uuid.MustParse("00000000-0000-7000-8000-00000000000a")
	repo := &fakeSyncRepo{currentCursor: 2}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Projects: []Project{{ID: dup}, {ID: dup}}},
	})

	var dupErr *DuplicateEntityIDsError
	if !errors.As(err, &dupErr) {
		t.Fatalf("expected DuplicateEntityIDsError, got %v", err)
	}
	if len(dupErr.IDs) != 1 || dupErr.IDs[0] != dup {
		t.Fatalf("expected the duplicated id to be reported, got %v", dupErr.IDs)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsDuplicateNoteIDs(t *testing.T) {
	dup := uuid.MustParse("00000000-0000-7000-8000-00000000000b")
	repo := &fakeSyncRepo{currentCursor: 2}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{note(dup.String()), note(dup.String())}},
	})

	var dupErr *DuplicateEntityIDsError
	if !errors.As(err, &dupErr) {
		t.Fatalf("expected DuplicateEntityIDsError, got %v", err)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsProjectIDOwnedByAnotherUser(t *testing.T) {
	foreign := uuid.MustParse("00000000-0000-7000-8000-00000000000c")
	repo := &fakeSyncRepo{
		currentCursor:     4,
		foreignProjectIDs: []uuid.UUID{foreign},
	}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Projects: []Project{{ID: foreign}}},
	})

	var conflictErr *OwnershipConflictError
	if !errors.As(err, &conflictErr) {
		t.Fatalf("expected OwnershipConflictError, got %v", err)
	}
	if conflictErr.Entity != "project" {
		t.Fatalf("expected entity 'project', got %q", conflictErr.Entity)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsNoteIDOwnedByAnotherUser(t *testing.T) {
	foreign := uuid.MustParse("00000000-0000-7000-8000-00000000000d")
	repo := &fakeSyncRepo{
		currentCursor:  4,
		foreignNoteIDs: []uuid.UUID{foreign},
	}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{note(foreign.String())}},
	})

	var conflictErr *OwnershipConflictError
	if !errors.As(err, &conflictErr) {
		t.Fatalf("expected OwnershipConflictError, got %v", err)
	}
	if conflictErr.Entity != "note" {
		t.Fatalf("expected entity 'note', got %q", conflictErr.Entity)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsNoteReferencingAnotherUsersProject(t *testing.T) {
	// The project exists but belongs to someone else, so the database reports
	// it as unavailable to the pushing user.
	foreignProject := uuid.MustParse("00000000-0000-7000-8000-00000000000e")
	repo := &fakeSyncRepo{currentCursor: 9, availableProjects: nil}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{
			ID:        uuid.MustParse("00000000-0000-7000-8000-00000000000f"),
			ProjectID: &foreignProject,
		}}},
	})

	var refErr *ProjectReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected ProjectReferenceError, got %v", err)
	}
	if len(refErr.IDs) != 1 || refErr.IDs[0] != foreignProject {
		t.Fatalf("expected the unavailable project to be reported, got %v", refErr.IDs)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsNoteReferencingUnknownProject(t *testing.T) {
	// Missing and foreign-owned projects must be reported identically so the
	// error cannot be used to discover which project IDs exist.
	missing := uuid.MustParse("00000000-0000-7000-8000-000000000010")
	repo := &fakeSyncRepo{currentCursor: 9}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{ID: uuid.New(), ProjectID: &missing}}},
	})

	var refErr *ProjectReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected ProjectReferenceError, got %v", err)
	}
	if len(refErr.IDs) != 1 {
		t.Fatalf("expected one unavailable project, got %v", refErr.IDs)
	}

	// The error text must not distinguish "missing" from "owned elsewhere".
	foreign := &ProjectReferenceError{IDs: []uuid.UUID{missing}}
	if foreign.Error() != refErr.Error() {
		t.Fatalf("error text should be identical regardless of why the project is unavailable")
	}
	assertNothingWritten(t, repo)
}

func TestSync_AcceptsNoteReferencingOwnProject(t *testing.T) {
	own := uuid.MustParse("00000000-0000-7000-8000-000000000011")
	repo := &fakeSyncRepo{currentCursor: 3, availableProjects: []uuid.UUID{own}}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{ID: uuid.New(), ProjectID: &own}}},
	})
	if err != nil {
		t.Fatalf("Sync: %v", err)
	}
	if res.NextCursor != 4 {
		t.Fatalf("expected cursor 4, got %d", res.NextCursor)
	}
	if len(repo.upsertNotes) != 1 {
		t.Fatalf("expected the note to be written, got %d upserts", len(repo.upsertNotes))
	}
}

func TestSync_AcceptsNoteReferencingProjectCreatedInSameBatch(t *testing.T) {
	// The offline workflow: a project and a note referencing it are pushed
	// together, so the project is not in the database during validation.
	projectID := uuid.MustParse("00000000-0000-7000-8000-000000000040")
	repo := &fakeSyncRepo{currentCursor: 7}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{{ID: projectID}},
			Notes:    []Note{{ID: uuid.New(), ProjectID: &projectID}},
		},
	})
	if err != nil {
		t.Fatalf("a project and a referencing note in one batch must be accepted: %v", err)
	}
	if res.NextCursor != 8 {
		t.Fatalf("expected cursor 8, got %d", res.NextCursor)
	}
	// Two lookups: the batch project's ownership check and the note
	// ownership check. A third would mean the in-batch reference still hit
	// the database, which is the bug this guards against.
	if repo.lookupCalls != 2 {
		t.Fatalf("expected project and note ownership lookups only, got %d", repo.lookupCalls)
	}
}

func TestSync_ValidatesOnlyExternalReferences(t *testing.T) {
	// A batch containing both a new project and a reference to a pre-existing
	// one must still check the external reference against the database.
	inBatch := uuid.MustParse("00000000-0000-7000-8000-000000000041")
	external := uuid.MustParse("00000000-0000-7000-8000-000000000042")
	repo := &fakeSyncRepo{currentCursor: 1, availableProjects: []uuid.UUID{external}}
	svc := newTestService(repo)

	if _, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{{ID: inBatch}},
			Notes:    []Note{{ID: uuid.New(), ProjectID: &external}},
		},
	}); err != nil {
		t.Fatalf("Sync: %v", err)
	}
}

func TestSync_RejectsExternalReferenceEvenWithInBatchProject(t *testing.T) {
	// The in-batch shortcut must not let a bad external reference through.
	inBatch := uuid.MustParse("00000000-0000-7000-8000-000000000043")
	bad := uuid.MustParse("00000000-0000-7000-8000-000000000044")
	repo := &fakeSyncRepo{currentCursor: 1}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{{ID: inBatch}},
			Notes:    []Note{{ID: uuid.New(), ProjectID: &bad}},
		},
	})

	var refErr *ProjectReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected ProjectReferenceError, got %v", err)
	}
	assertNothingWritten(t, repo)
}

func TestSync_UnreferencedNotesSkipProjectLookup(t *testing.T) {
	repo := &fakeSyncRepo{currentCursor: 1}
	svc := newTestService(repo)

	if _, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{note(uuid.New().String())}},
	}); err != nil {
		t.Fatalf("Sync: %v", err)
	}

	// Only the note-ownership check should have run.
	if repo.lookupCalls != 1 {
		t.Fatalf("expected exactly one ownership lookup, got %d", repo.lookupCalls)
	}
}

func TestFindDuplicateIDs(t *testing.T) {
	a := uuid.MustParse("00000000-0000-7000-8000-000000000020")
	b := uuid.MustParse("00000000-0000-7000-8000-000000000021")

	if got := findDuplicateIDs([]uuid.UUID{a, b}); len(got) != 0 {
		t.Fatalf("expected no duplicates, got %v", got)
	}
	if got := findDuplicateIDs([]uuid.UUID{a, a}); len(got) != 1 || got[0] != a {
		t.Fatalf("expected one duplicate equal to a, got %v", got)
	}
	// A triplicate reports the id once, not twice.
	if got := findDuplicateIDs([]uuid.UUID{a, a, a}); len(got) != 1 {
		t.Fatalf("expected the triplicate id reported once, got %v", got)
	}
}

func TestReferencedProjectIDs(t *testing.T) {
	a := uuid.MustParse("00000000-0000-7000-8000-000000000030")
	b := uuid.MustParse("00000000-0000-7000-8000-000000000031")

	got := referencedProjectIDs([]Note{
		{ID: uuid.New()},
		{ID: uuid.New(), ProjectID: &a},
		{ID: uuid.New(), ProjectID: &a},
		{ID: uuid.New(), ProjectID: &b},
	})
	if len(got) != 2 || got[0] != a || got[1] != b {
		t.Fatalf("expected distinct references [a b], got %v", got)
	}
}

// assertNothingWritten checks that a rejected batch left no trace: the cursor
// must not move and no row may be upserted. The fake only mutates its cursor
// inside UpdateUserCursor, so an empty update list proves the cursor is intact.
func assertNothingWritten(t *testing.T, repo *fakeSyncRepo) {
	t.Helper()

	if len(repo.cursorUpdates) != 0 {
		t.Fatalf("cursor must not move on a rejected batch, got %v", repo.cursorUpdates)
	}
	if len(repo.upsertProjects) != 0 || len(repo.upsertNotes) != 0 {
		t.Fatalf("no entity may be written on a rejected batch, got %d project and %d note upserts",
			len(repo.upsertProjects), len(repo.upsertNotes))
	}
}
