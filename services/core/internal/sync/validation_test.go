package sync

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
)

func TestSync_RejectsDuplicateNotebookIDs(t *testing.T) {
	dup := uuid.MustParse("00000000-0000-7000-8000-00000000000a")
	repo := &fakeSyncRepo{currentCursor: 2}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notebooks: []Notebook{{ID: dup}, {ID: dup}}},
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

func TestSync_RejectsNotebookIDOwnedByAnotherUser(t *testing.T) {
	foreign := uuid.MustParse("00000000-0000-7000-8000-00000000000c")
	repo := &fakeSyncRepo{
		currentCursor:     4,
		foreignNotebookIDs: []uuid.UUID{foreign},
	}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notebooks: []Notebook{{ID: foreign}}},
	})

	var conflictErr *OwnershipConflictError
	if !errors.As(err, &conflictErr) {
		t.Fatalf("expected OwnershipConflictError, got %v", err)
	}
	if conflictErr.Entity != "notebook" {
		t.Fatalf("expected entity 'notebook', got %q", conflictErr.Entity)
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

func TestSync_RejectsNoteReferencingAnotherUsersNotebook(t *testing.T) {
	// The notebook exists but belongs to someone else, so the database reports
	// it as unavailable to the pushing user.
	foreignNotebook := uuid.MustParse("00000000-0000-7000-8000-00000000000e")
	repo := &fakeSyncRepo{currentCursor: 9, availableNotebooks: nil}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{
			ID:        uuid.MustParse("00000000-0000-7000-8000-00000000000f"),
			NotebookID: &foreignNotebook,
		}}},
	})

	var refErr *NotebookReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected NotebookReferenceError, got %v", err)
	}
	if len(refErr.IDs) != 1 || refErr.IDs[0] != foreignNotebook {
		t.Fatalf("expected the unavailable notebook to be reported, got %v", refErr.IDs)
	}
	assertNothingWritten(t, repo)
}

func TestSync_RejectsNoteReferencingUnknownNotebook(t *testing.T) {
	// Missing and foreign-owned notebooks must be reported identically so the
	// error cannot be used to discover which notebook IDs exist.
	missing := uuid.MustParse("00000000-0000-7000-8000-000000000010")
	repo := &fakeSyncRepo{currentCursor: 9}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{ID: uuid.New(), NotebookID: &missing}}},
	})

	var refErr *NotebookReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected NotebookReferenceError, got %v", err)
	}
	if len(refErr.IDs) != 1 {
		t.Fatalf("expected one unavailable notebook, got %v", refErr.IDs)
	}

	// The error text must not distinguish "missing" from "owned elsewhere".
	foreign := &NotebookReferenceError{IDs: []uuid.UUID{missing}}
	if foreign.Error() != refErr.Error() {
		t.Fatalf("error text should be identical regardless of why the notebook is unavailable")
	}
	assertNothingWritten(t, repo)
}

func TestSync_AcceptsNoteReferencingOwnNotebook(t *testing.T) {
	own := uuid.MustParse("00000000-0000-7000-8000-000000000011")
	repo := &fakeSyncRepo{currentCursor: 3, availableNotebooks: []uuid.UUID{own}}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{Notes: []Note{{ID: uuid.New(), NotebookID: &own}}},
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

func TestSync_AcceptsNoteReferencingNotebookCreatedInSameBatch(t *testing.T) {
	// The offline workflow: a notebook and a note referencing it are pushed
	// together, so the notebook is not in the database during validation.
	notebookID := uuid.MustParse("00000000-0000-7000-8000-000000000040")
	repo := &fakeSyncRepo{currentCursor: 7}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{{ID: notebookID}},
			Notes:    []Note{{ID: uuid.New(), NotebookID: &notebookID}},
		},
	})
	if err != nil {
		t.Fatalf("a notebook and a referencing note in one batch must be accepted: %v", err)
	}
	if res.NextCursor != 8 {
		t.Fatalf("expected cursor 8, got %d", res.NextCursor)
	}
	// Two lookups: the batch notebook's ownership check and the note
	// ownership check. A third would mean the in-batch reference still hit
	// the database, which is the bug this guards against.
	if repo.lookupCalls != 2 {
		t.Fatalf("expected notebook and note ownership lookups only, got %d", repo.lookupCalls)
	}
}

func TestSync_ValidatesOnlyExternalReferences(t *testing.T) {
	// A batch containing both a new notebook and a reference to a pre-existing
	// one must still check the external reference against the database.
	inBatch := uuid.MustParse("00000000-0000-7000-8000-000000000041")
	external := uuid.MustParse("00000000-0000-7000-8000-000000000042")
	repo := &fakeSyncRepo{currentCursor: 1, availableNotebooks: []uuid.UUID{external}}
	svc := newTestService(repo)

	if _, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{{ID: inBatch}},
			Notes:    []Note{{ID: uuid.New(), NotebookID: &external}},
		},
	}); err != nil {
		t.Fatalf("Sync: %v", err)
	}
}

func TestSync_RejectsExternalReferenceEvenWithInBatchNotebook(t *testing.T) {
	// The in-batch shortcut must not let a bad external reference through.
	inBatch := uuid.MustParse("00000000-0000-7000-8000-000000000043")
	bad := uuid.MustParse("00000000-0000-7000-8000-000000000044")
	repo := &fakeSyncRepo{currentCursor: 1}
	svc := newTestService(repo)

	_, err := svc.Sync(context.Background(), 1, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{{ID: inBatch}},
			Notes:    []Note{{ID: uuid.New(), NotebookID: &bad}},
		},
	})

	var refErr *NotebookReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected NotebookReferenceError, got %v", err)
	}
	assertNothingWritten(t, repo)
}

func TestSync_UnreferencedNotesSkipNotebookLookup(t *testing.T) {
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

func TestReferencedNotebookIDs(t *testing.T) {
	a := uuid.MustParse("00000000-0000-7000-8000-000000000030")
	b := uuid.MustParse("00000000-0000-7000-8000-000000000031")

	got := referencedNotebookIDs([]Note{
		{ID: uuid.New()},
		{ID: uuid.New(), NotebookID: &a},
		{ID: uuid.New(), NotebookID: &a},
		{ID: uuid.New(), NotebookID: &b},
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
	if len(repo.upsertNotebooks) != 0 || len(repo.upsertNotes) != 0 {
		t.Fatalf("no entity may be written on a rejected batch, got %d notebook and %d note upserts",
			len(repo.upsertNotebooks), len(repo.upsertNotes))
	}
}
