package sync

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
)

type fakeSyncRepo struct {
	currentCursor int

	upsertNotebooks    [][]Notebook
	upsertNotes       [][]Note
	upsertSequences   []int
	upsertUserIDs     []int
	notebooksFetchedAt []int
	notesFetchedAt    []int
	cursorUpdates     []int
	lockedCursorReads int

	// Ownership fixtures: IDs the database reports as belonging to someone
	// else, and IDs this account can actually use.
	foreignNotebookIDs []uuid.UUID
	foreignNoteIDs    []uuid.UUID
	availableNotebooks []uuid.UUID

	lookupCalls int
}

func (f *fakeSyncRepo) GetUserCursor(context.Context, int) (int, error) {
	return f.currentCursor, nil
}

func (f *fakeSyncRepo) GetUserCursorForUpdate(_ context.Context, _ int) (int, error) {
	f.lockedCursorReads++
	return f.currentCursor, nil
}

func (f *fakeSyncRepo) UpdateUserCursor(_ context.Context, _ int, cursor int) error {
	f.cursorUpdates = append(f.cursorUpdates, cursor)
	f.currentCursor = cursor
	return nil
}

func (f *fakeSyncRepo) UpsertNotebooks(_ context.Context, userID, seq int, notebooks []Notebook) error {
	f.upsertUserIDs = append(f.upsertUserIDs, userID)
	f.upsertNotebooks = append(f.upsertNotebooks, notebooks)
	f.upsertSequences = append(f.upsertSequences, seq)
	return nil
}

func (f *fakeSyncRepo) UpsertNotes(_ context.Context, userID, seq int, notes []Note) error {
	f.upsertUserIDs = append(f.upsertUserIDs, userID)
	f.upsertNotes = append(f.upsertNotes, notes)
	f.upsertSequences = append(f.upsertSequences, seq)
	return nil
}

func (f *fakeSyncRepo) GetNotebookChanges(_ context.Context, _ int, cursor int) ([]Notebook, error) {
	f.notebooksFetchedAt = append(f.notebooksFetchedAt, cursor)
	return nil, nil
}

func (f *fakeSyncRepo) GetNoteChanges(_ context.Context, _ int, cursor int) ([]Note, error) {
	f.notesFetchedAt = append(f.notesFetchedAt, cursor)
	return nil, nil
}

func (f *fakeSyncRepo) FindNotebookIDsOwnedByOtherUsers(_ context.Context, _ []uuid.UUID, _ int) ([]uuid.UUID, error) {
	f.lookupCalls++
	return f.foreignNotebookIDs, nil
}

func (f *fakeSyncRepo) FindNoteIDsOwnedByOtherUsers(_ context.Context, _ []uuid.UUID, _ int) ([]uuid.UUID, error) {
	f.lookupCalls++
	return f.foreignNoteIDs, nil
}

func (f *fakeSyncRepo) FindNotebookIDsAvailableToUser(_ context.Context, _ []uuid.UUID, _ int) ([]uuid.UUID, error) {
	f.lookupCalls++
	return f.availableNotebooks, nil
}

type fakeTransactor struct{}

func (fakeTransactor) WithinTransaction(ctx context.Context, fn func(ctx context.Context) error) error {
	return fn(ctx)
}

func newTestService(repo *fakeSyncRepo) *SyncService {
	return NewSyncService(fakeTransactor{}, repo)
}

func note(id string) Note {
	return Note{ID: uuid.MustParse(id), CreatedAt: time.Now(), UpdatedAt: time.Now()}
}

func TestSync_PushIncrementsCursorOnce(t *testing.T) {
	repo := &fakeSyncRepo{currentCursor: 5}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		ClientCursor: 3,
		Changes: SyncChanges{
			Notes:    []Note{note("00000000-0000-7000-8000-000000000001")},
			Notebooks: []Notebook{{ID: uuid.New()}},
		},
	})
	if err != nil {
		t.Fatalf("Sync: %v", err)
	}

	if res.NextCursor != 6 {
		t.Fatalf("cursor should increment exactly once: 5 -> 6, got %d", res.NextCursor)
	}
	if len(repo.cursorUpdates) != 1 || repo.cursorUpdates[0] != 6 {
		t.Fatalf("cursor update should happen once with value 6, got %v", repo.cursorUpdates)
	}
	if repo.lockedCursorReads != 1 {
		t.Fatalf("push sync should lock the cursor once, got %d", repo.lockedCursorReads)
	}

	for i, seq := range repo.upsertSequences {
		if seq != 6 {
			t.Fatalf("upsert %d must be stamped with the new sequence 6, got %d", i, seq)
		}
	}
}

func TestSync_PullOnlyKeepsCursorUntouched(t *testing.T) {
	repo := &fakeSyncRepo{currentCursor: 9}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{ClientCursor: 4})
	if err != nil {
		t.Fatalf("Sync: %v", err)
	}

	if res.NextCursor != 9 {
		t.Fatalf("pull-only sync must not move the cursor, got %d", res.NextCursor)
	}
	if len(repo.cursorUpdates) != 0 || len(repo.upsertNotes) != 0 || len(repo.upsertNotebooks) != 0 {
		t.Fatal("pull-only sync must not write anything")
	}
	if repo.lockedCursorReads != 0 {
		t.Fatalf("pull-only sync must not take the cursor write lock, got %d", repo.lockedCursorReads)
	}

	if len(repo.notebooksFetchedAt) != 1 || repo.notebooksFetchedAt[0] != 4 {
		t.Fatalf("notebook changes should be fetched from client cursor 4, got %v", repo.notebooksFetchedAt)
	}
	if len(repo.notesFetchedAt) != 1 || repo.notesFetchedAt[0] != 4 {
		t.Fatalf("note changes should be fetched from client cursor 4, got %v", repo.notesFetchedAt)
	}
}

func TestSync_EmptyPushCountsAsPull(t *testing.T) {
	repo := &fakeSyncRepo{currentCursor: 2}
	svc := newTestService(repo)

	res, err := svc.Sync(context.Background(), 1, SyncPayload{
		ClientCursor: 2,
		Changes:      SyncChanges{Notes: []Note{}, Notebooks: []Notebook{}},
	})
	if err != nil {
		t.Fatalf("Sync: %v", err)
	}

	if res.NextCursor != 2 {
		t.Fatalf("empty changes must not increment cursor, got %d", res.NextCursor)
	}
}

// Regression test for T-01's client-facing contract: the payload the server
// stores must carry the authenticated user's ID, never a client-chosen one.
func TestSync_UpsertUsesAuthenticatedUserID(t *testing.T) {
	repo := &fakeSyncRepo{}
	svc := newTestService(repo)

	p := Notebook{ID: uuid.New()}
	n := note("00000000-0000-7000-8000-000000000002")

	_, err := svc.Sync(context.Background(), 77, SyncPayload{
		ClientCursor: 0,
		Changes:      SyncChanges{Notebooks: []Notebook{p}, Notes: []Note{n}},
	})
	if err != nil {
		t.Fatalf("Sync: %v", err)
	}

	for i, uid := range repo.upsertUserIDs {
		if uid != 77 {
			t.Fatalf("upsert %d must target authenticated userID 77, got %d", i, uid)
		}
	}
	if len(repo.upsertUserIDs) != 2 {
		t.Fatalf("expected one notebook and one note upsert, got %d", len(repo.upsertUserIDs))
	}
}
