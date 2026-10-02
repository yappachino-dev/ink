package sync

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/yappachino-dev/ink/services/core/internal/database"
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

// newIntegrationService wires the real PostgreSQL repository and transactor
// against a throwaway container, so validation runs through the actual SQL
// rather than through a fake.
func newIntegrationService(t *testing.T) (*SyncService, *pgxpool.Pool, int, int) {
	t.Helper()

	pool := dbtest.StartPostgres(t)
	q := store.New(pool)

	alice := seedUser(t, q)
	bob := seedUser(t, q)

	svc := NewSyncService(database.NewPgTransactor(pool), NewPostgresSyncRepository(q))

	return svc, pool, alice, bob
}

// seedNotebook inserts a notebook directly, bypassing the service, so ownership
// fixtures exist before any push is attempted.
func seedNotebook(t *testing.T, pool *pgxpool.Pool, userID int) uuid.UUID {
	t.Helper()

	id := uuid.New()
	_, err := pool.Exec(context.Background(),
		`INSERT INTO notebooks (id, user_id, encrypted_content, version, sync_sequence, created_at, updated_at)
		 VALUES ($1, $2, $3, 1, 0, NOW(), NOW())`,
		id, userID, []byte("original"))
	if err != nil {
		t.Fatalf("seed notebook: %v", err)
	}

	return id
}

func notebookChange(id uuid.UUID) Notebook {
	now := time.Now().UTC()

	return Notebook{
		ID:               id,
		EncryptedContent: []byte("pushed"),
		Version:          1,
		CreatedAt:        now,
		UpdatedAt:        now,
	}
}

func noteChange(id uuid.UUID, notebookID *uuid.UUID) Note {
	now := time.Now().UTC()

	return Note{
		ID:               id,
		NotebookID:       notebookID,
		EncryptedTitle:   []byte("t"),
		EncryptedContent: []byte("c"),
		Version:          1,
		CreatedAt:        now,
		UpdatedAt:        now,
	}
}

func notebookContent(t *testing.T, pool *pgxpool.Pool, id uuid.UUID) []byte {
	t.Helper()

	var content []byte
	if err := pool.QueryRow(context.Background(),
		`SELECT encrypted_content FROM notebooks WHERE id = $1`, id).Scan(&content); err != nil {
		t.Fatalf("read notebook row: %v", err)
	}

	return content
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

func TestNotebookChangesRoundTrip(t *testing.T) {
	repo, q := newRepo(t)
	ctx := context.Background()
	userID := seedUser(t, q)

	live := Notebook{
		ID:               uuid.New(),
		UserID:           userID,
		EncryptedContent: []byte("live-content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC(),
		UpdatedAt:        time.Now().UTC(),
	}
	tombstoned := Notebook{
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
	if err := repo.UpsertNotebooks(ctx, userID, 1, []Notebook{live, tombstoned}); err != nil {
		t.Fatalf("upsert notebooks: %v", err)
	}

	// Cursor 0 returns everything; the tombstone must carry its deleted_at.
	all, err := repo.GetNotebookChanges(ctx, userID, 0)
	if err != nil {
		t.Fatalf("get changes: %v", err)
	}
	if len(all) != 2 {
		t.Fatalf("expected 2 changes, got %d", len(all))
	}
	byID := map[uuid.UUID]Notebook{all[0].ID: all[0], all[1].ID: all[1]}
	if got := byID[live.ID]; got.DeletedAt != (time.Time{}) || string(got.EncryptedContent) != "live-content" {
		t.Fatalf("live notebook mismatch: %+v", got)
	}
	if got := byID[tombstoned.ID]; got.DeletedAt.IsZero() {
		t.Fatal("tombstone lost deleted_at")
	}

	// Incremental pull past that window sees nothing yet.
	fresh, err := repo.GetNotebookChanges(ctx, userID, 1)
	if err != nil || len(fresh) != 0 {
		t.Fatalf("expected empty incremental window: %+v, %v", fresh, err)
	}

	// Re-pushing bumps the change into a later window.
	live.Version = 2
	live.SyncSequence = 2
	if err := repo.UpsertNotebooks(ctx, userID, 2, []Notebook{live}); err != nil {
		t.Fatalf("re-upsert: %v", err)
	}
	fresh, err = repo.GetNotebookChanges(ctx, userID, 1)
	if err != nil || len(fresh) != 1 || fresh[0].Version != 2 || fresh[0].ID != live.ID {
		t.Fatalf("re-upsert not visible incrementally: %+v, %v", fresh, err)
	}
}

func TestNoteChangesRoundTrip(t *testing.T) {
	repo, q := newRepo(t)
	ctx := context.Background()
	userID := seedUser(t, q)

	notebookID := uuid.New()
	if err := repo.UpsertNotebooks(ctx, userID, 1, []Notebook{{
		ID:               notebookID,
		UserID:           userID,
		EncryptedContent: []byte("notebook-content"),
		Version:          1,
		SyncSequence:     1,
		CreatedAt:        time.Now().UTC(),
		UpdatedAt:        time.Now().UTC(),
	}}); err != nil {
		t.Fatalf("seed notebook: %v", err)
	}

	orphan := uuid.New() // no matching notebook row; FK must be satisfied by NULL
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
	withNotebook := note
	withNotebook.ID = uuid.New()
	withNotebook.NotebookID = &notebookID
	orphanNote := note
	orphanNote.ID = orphan

	if err := repo.UpsertNotes(ctx, userID, 1, []Note{withNotebook, orphanNote}); err != nil {
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
	if n := byID[withNotebook.ID]; n.NotebookID == nil || *n.NotebookID != notebookID {
		t.Fatalf("notebook_id not round-tripped: %+v", n)
	}
	if n := byID[orphan]; n.NotebookID != nil {
		t.Fatalf("nil notebook should stay nil, got %v", *n.NotebookID)
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

// TestSyncIntegration_AcceptsNewNotebookAndReferencingNoteInSameBatch covers the
// core offline workflow: a notebook and a note referencing it are created while
// disconnected and pushed in one batch. At validation time the notebook does not
// exist in the database yet, so the reference must be resolved against the
// batch itself.
func TestSyncIntegration_AcceptsNewNotebookAndReferencingNoteInSameBatch(t *testing.T) {
	svc, pool, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	notebookID := uuid.New()
	noteID := uuid.New()

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{notebookChange(notebookID)},
			Notes:     []Note{noteChange(noteID, &notebookID)},
		},
	}); err != nil {
		t.Fatalf("creating a notebook and a referencing note in one push must succeed: %v", err)
	}

	repo := NewPostgresSyncRepository(store.New(pool))

	notes, err := repo.GetNoteChanges(ctx, alice, 0)
	if err != nil {
		t.Fatalf("get note changes: %v", err)
	}
	if len(notes) != 1 {
		t.Fatalf("expected 1 stored note, got %d", len(notes))
	}
	if notes[0].NotebookID == nil || *notes[0].NotebookID != notebookID {
		t.Fatalf("note lost its notebook reference: %+v", notes[0])
	}

	notebooks, err := repo.GetNotebookChanges(ctx, alice, 0)
	if err != nil {
		t.Fatalf("get notebook changes: %v", err)
	}
	if len(notebooks) != 1 || notebooks[0].ID != notebookID {
		t.Fatalf("expected the new notebook to be stored, got %d notebooks", len(notebooks))
	}
}

func TestSyncIntegration_AcceptsMixedBatchAndExternalReference(t *testing.T) {
	// Half the references ship in the batch, half pre-exist. The external one
	// must still be validated against the database.
	svc, pool, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	existing := seedNotebook(t, pool, alice)
	inBatch := uuid.New()

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{notebookChange(inBatch)},
			Notes: []Note{
				noteChange(uuid.New(), &inBatch),
				noteChange(uuid.New(), &existing),
			},
		},
	}); err != nil {
		t.Fatalf("mixed batch should succeed: %v", err)
	}
}

func TestSyncIntegration_RejectsCrossUserNotebookID(t *testing.T) {
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsNotebook := seedNotebook(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		ClientCursor: 0,
		Changes:      SyncChanges{Notebooks: []Notebook{notebookChange(bobsNotebook)}},
	})

	var conflict *OwnershipConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected OwnershipConflictError, got %v", err)
	}
	if len(conflict.IDs) != 1 || conflict.IDs[0] != bobsNotebook {
		t.Fatalf("expected Bob's notebook id to be reported, got %v", conflict.IDs)
	}
}

func TestSyncIntegration_SilentNoOpIsGone(t *testing.T) {
	// The upsert guard `WHERE user_id = EXCLUDED.user_id` made a cross-user id
	// a successful no-op. Verify Bob's row is genuinely untouched afterwards.
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsNotebook := seedNotebook(t, pool, bob)
	original := notebookContent(t, pool, bobsNotebook)

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Notebooks: []Notebook{notebookChange(bobsNotebook)}},
	}); err == nil {
		t.Fatal("expected the push to be rejected, got success")
	}

	if after := notebookContent(t, pool, bobsNotebook); string(after) != string(original) {
		t.Fatalf("Bob's notebook was modified by Alice's push: %q -> %q", original, after)
	}
}

func TestSyncIntegration_RejectsNoteReferencingCrossUserNotebook(t *testing.T) {
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsNotebook := seedNotebook(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Notes: []Note{noteChange(uuid.New(), &bobsNotebook)}},
	})

	var refErr *NotebookReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected NotebookReferenceError, got %v", err)
	}
}

func TestSyncIntegration_RejectsNoteReferencingNotebookInSameBatchOwnedElsewhere(t *testing.T) {
	// A notebook in the batch clears step 2 only if it is genuinely the user's;
	// pushing Bob's id together with a note referencing it must still fail.
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsNotebook := seedNotebook(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Notebooks: []Notebook{notebookChange(bobsNotebook)},
			Notes:     []Note{noteChange(uuid.New(), &bobsNotebook)},
		},
	})

	var conflict *OwnershipConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected OwnershipConflictError from the batch notebook, got %v", err)
	}
}

func TestSyncIntegration_RejectsDuplicateIDsInBatch(t *testing.T) {
	svc, _, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	change := notebookChange(uuid.New())

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Notebooks: []Notebook{change, change}},
	})

	var dupErr *DuplicateEntityIDsError
	if !errors.As(err, &dupErr) {
		t.Fatalf("expected DuplicateEntityIDsError, got %v", err)
	}
}
