package sync

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/yappachino-dev/ink/services/core/internal/database/dbtest"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

func newRepo(t *testing.T) (*PostgresSyncRepository, *store.Queries) {
	t.Helper()
	pool := dbtest.StartPostgres(t)
	q := store.New(pool)
	return NewPostgresSyncRepository(q), q
}

func seedUser(t *testing.T, q *store.Queries) int {
	t.Helper()
	ctx := context.Background()
	row, err := q.CreateUser(ctx, store.CreateUserParams{
		Email:        uuid.NewString() + "@example.com",
		PasswordHash: "hash",
	})
	if err != nil {
		t.Fatalf("seed user: %v", err)
	}
	return int(row.ID)
}

func TestCursorRoundTrip(t *testing.T) {
	repo, q := newRepo(t)
	ctx := context.Background()
	userID := seedUser(t, q)

	cursor, err := repo.GetUserCursor(ctx, userID)
	if err != nil || cursor != 0 {
		t.Fatalf("initial cursor: %d, %v", cursor, err)
	}

	if err := repo.UpdateUserCursor(ctx, userID, 42); err != nil {
		t.Fatalf("update cursor: %v", err)
	}
	cursor, err = repo.GetUserCursor(ctx, userID)
	if err != nil || cursor != 42 {
		t.Fatalf("cursor after update: %d, %v", cursor, err)
	}
}

func TestProjectChangesRoundTrip(t *testing.T) {
	repo, q := newRepo(t)
	ctx := context.Background()
	userID := seedUser(t, q)

	live := Project{
		ID:               uuid.New(),
		UserID:           userID,
		EncryptedContent: []byte("live-content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC(),
		UpdatedAt:        time.Now().UTC(),
	}
	tombstoned := Project{
		ID:               uuid.New(),
		UserID:           userID,
		EncryptedContent: []byte("tombstone-content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC().Add(-time.Hour),
		UpdatedAt:        time.Now().UTC(),
		DeletedAt:        time.Now().UTC(),
	}
	// The repository stamps every pushed row with one sync sequence.
	if err := repo.UpsertProjects(ctx, userID, 1, []Project{live, tombstoned}); err != nil {
		t.Fatalf("upsert projects: %v", err)
	}

	// Cursor 0 returns everything; the tombstone must carry its deleted_at.
	all, err := repo.GetProjectChanges(ctx, userID, 0)
	if err != nil {
		t.Fatalf("get changes: %v", err)
	}
	if len(all) != 2 {
		t.Fatalf("expected 2 changes, got %d", len(all))
	}
	byID := map[uuid.UUID]Project{all[0].ID: all[0], all[1].ID: all[1]}
	if got := byID[live.ID]; got.DeletedAt != (time.Time{}) || string(got.EncryptedContent) != "live-content" {
		t.Fatalf("live project mismatch: %+v", got)
	}
	if got := byID[tombstoned.ID]; got.DeletedAt.IsZero() {
		t.Fatal("tombstone lost deleted_at")
	}

	// Incremental pull past that window sees nothing yet.
	fresh, err := repo.GetProjectChanges(ctx, userID, 1)
	if err != nil || len(fresh) != 0 {
		t.Fatalf("expected empty incremental window: %+v, %v", fresh, err)
	}

	// Re-pushing bumps the change into a later window.
	live.Version = 2
	live.SyncSequence = 2
	if err := repo.UpsertProjects(ctx, userID, 2, []Project{live}); err != nil {
		t.Fatalf("re-upsert: %v", err)
	}
	fresh, err = repo.GetProjectChanges(ctx, userID, 1)
	if err != nil || len(fresh) != 1 || fresh[0].Version != 2 || fresh[0].ID != live.ID {
		t.Fatalf("re-upsert not visible incrementally: %+v, %v", fresh, err)
	}
}

func TestNoteChangesRoundTrip(t *testing.T) {
	repo, q := newRepo(t)
	ctx := context.Background()
	userID := seedUser(t, q)

	projectID := uuid.New()
	if err := repo.UpsertProjects(ctx, userID, 1, []Project{{
		ID:               projectID,
		UserID:           userID,
		EncryptedContent: []byte("project-content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC(),
		UpdatedAt:        time.Now().UTC(),
	}}); err != nil {
		t.Fatalf("seed project: %v", err)
	}

	orphan := uuid.New() // no matching project row; FK must be satisfied by NULL
	note := Note{
		ID:               uuid.New(),
		UserID:           userID,
		EncryptedTitle:   []byte("title"),
		EncryptedContent: []byte("content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC(),
		UpdatedAt:        time.Now().UTC(),
	}
	withProject := note
	withProject.ID = uuid.New()
	withProject.ProjectID = &projectID
	orphanNote := note
	orphanNote.ID = orphan

	if err := repo.UpsertNotes(ctx, userID, 1, []Note{withProject, orphanNote}); err != nil {
		t.Fatalf("upsert notes: %v", err)
	}

	got, err := repo.GetNoteChanges(ctx, userID, 0)
	if err != nil {
		t.Fatalf("get changes: %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("expected 2 notes, got %d", len(got))
	}
	byID := map[uuid.UUID]Note{got[0].ID: got[0], got[1].ID: got[1]}
	if n := byID[withProject.ID]; n.ProjectID == nil || *n.ProjectID != projectID {
		t.Fatalf("project_id not round-tripped: %+v", n)
	}
	if n := byID[orphan]; n.ProjectID != nil {
		t.Fatalf("nil project should stay nil, got %v", *n.ProjectID)
	}
	if n := byID[orphan]; string(n.EncryptedTitle) != "title" || n.DeletedAt != (time.Time{}) {
		t.Fatalf("orphan content mismatch: %+v", n)
	}

	// Tombstone round-trip.
	tombstone := orphanNote
	tombstone.Version = 2
	tombstone.SyncSequence = 2
	tombstone.DeletedAt = time.Now().UTC()
	if err := repo.UpsertNotes(ctx, userID, 2, []Note{tombstone}); err != nil {
		t.Fatalf("tombstone upsert: %v", err)
	}
	fresh, err := repo.GetNoteChanges(ctx, userID, 1)
	if err != nil || len(fresh) != 1 || fresh[0].DeletedAt.IsZero() {
		t.Fatalf("tombstone not visible incrementally: %+v, %v", fresh, err)
	}
}
