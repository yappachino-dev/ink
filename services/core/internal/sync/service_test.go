package sync

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
)

type fakeSyncRepo struct {
	currentCursor int

	upsertProjects    [][]Project
	upsertNotes       [][]Note
	upsertSequences   []int
	upsertUserIDs     []int
	projectsFetchedAt []int
	notesFetchedAt    []int
	cursorUpdates     []int
}

func (f *fakeSyncRepo) GetUserCursor(context.Context, int) (int, error) {
	return f.currentCursor, nil
}

func (f *fakeSyncRepo) UpdateUserCursor(_ context.Context, _ int, cursor int) error {
	f.cursorUpdates = append(f.cursorUpdates, cursor)
	f.currentCursor = cursor
	return nil
}

func (f *fakeSyncRepo) UpsertProjects(_ context.Context, userID, seq int, projects []Project) error {
	f.upsertUserIDs = append(f.upsertUserIDs, userID)
	f.upsertProjects = append(f.upsertProjects, projects)
	f.upsertSequences = append(f.upsertSequences, seq)
	return nil
}

func (f *fakeSyncRepo) UpsertNotes(_ context.Context, userID, seq int, notes []Note) error {
	f.upsertUserIDs = append(f.upsertUserIDs, userID)
	f.upsertNotes = append(f.upsertNotes, notes)
	f.upsertSequences = append(f.upsertSequences, seq)
	return nil
}

func (f *fakeSyncRepo) GetProjectChanges(_ context.Context, _ int, cursor int) ([]Project, error) {
	f.projectsFetchedAt = append(f.projectsFetchedAt, cursor)
	return nil, nil
}

func (f *fakeSyncRepo) GetNoteChanges(_ context.Context, _ int, cursor int) ([]Note, error) {
	f.notesFetchedAt = append(f.notesFetchedAt, cursor)
	return nil, nil
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
			Projects: []Project{{ID: uuid.New()}},
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
	if len(repo.cursorUpdates) != 0 || len(repo.upsertNotes) != 0 || len(repo.upsertProjects) != 0 {
		t.Fatal("pull-only sync must not write anything")
	}

	if len(repo.projectsFetchedAt) != 1 || repo.projectsFetchedAt[0] != 4 {
		t.Fatalf("project changes should be fetched from client cursor 4, got %v", repo.projectsFetchedAt)
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
		Changes:      SyncChanges{Notes: []Note{}, Projects: []Project{}},
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

	p := Project{ID: uuid.New()}
	n := note("00000000-0000-7000-8000-000000000002")

	_, err := svc.Sync(context.Background(), 77, SyncPayload{
		ClientCursor: 0,
		Changes:      SyncChanges{Projects: []Project{p}, Notes: []Note{n}},
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
		t.Fatalf("expected one project and one note upsert, got %d", len(repo.upsertUserIDs))
	}
}
