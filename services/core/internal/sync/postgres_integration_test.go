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

// seedProject inserts a project directly, bypassing the service, so ownership
// fixtures exist before any push is attempted.
func seedProject(t *testing.T, pool *pgxpool.Pool, userID int) uuid.UUID {
	t.Helper()

	id := uuid.New()
	_, err := pool.Exec(context.Background(),
		`INSERT INTO projects (id, user_id, encrypted_content, version, sync_sequence, created_at, updated_at)
		 VALUES ($1, $2, $3, 1, 0, NOW(), NOW())`,
		id, userID, []byte("original"))
	if err != nil {
		t.Fatalf("seed project: %v", err)
	}

	return id
}

func projectChange(id uuid.UUID) Project {
	now := time.Now().UTC()

	return Project{
		ID:               id,
		EncryptedContent: []byte("pushed"),
		Version:          1,
		CreatedAt:        now,
		UpdatedAt:        now,
	}
}

func noteChange(id uuid.UUID, projectID *uuid.UUID) Note {
	now := time.Now().UTC()

	return Note{
		ID:               id,
		ProjectID:        projectID,
		EncryptedTitle:   []byte("t"),
		EncryptedContent: []byte("c"),
		Version:          1,
		CreatedAt:        now,
		UpdatedAt:        now,
	}
}

func projectContent(t *testing.T, pool *pgxpool.Pool, id uuid.UUID) []byte {
	t.Helper()

	var content []byte
	if err := pool.QueryRow(context.Background(),
		`SELECT encrypted_content FROM projects WHERE id = $1`, id).Scan(&content); err != nil {
		t.Fatalf("read project row: %v", err)
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

// TestSyncIntegration_AcceptsNewProjectAndReferencingNoteInSameBatch covers the
// core offline workflow: a project and a note referencing it are created while
// disconnected and pushed in one batch. At validation time the project does not
// exist in the database yet, so the reference must be resolved against the
// batch itself.
func TestSyncIntegration_AcceptsNewProjectAndReferencingNoteInSameBatch(t *testing.T) {
	svc, pool, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	projectID := uuid.New()
	noteID := uuid.New()

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{projectChange(projectID)},
			Notes:    []Note{noteChange(noteID, &projectID)},
		},
	}); err != nil {
		t.Fatalf("creating a project and a referencing note in one push must succeed: %v", err)
	}

	repo := NewPostgresSyncRepository(store.New(pool))

	notes, err := repo.GetNoteChanges(ctx, alice, 0)
	if err != nil {
		t.Fatalf("get note changes: %v", err)
	}
	if len(notes) != 1 {
		t.Fatalf("expected 1 stored note, got %d", len(notes))
	}
	if notes[0].ProjectID == nil || *notes[0].ProjectID != projectID {
		t.Fatalf("note lost its project reference: %+v", notes[0])
	}

	projects, err := repo.GetProjectChanges(ctx, alice, 0)
	if err != nil {
		t.Fatalf("get project changes: %v", err)
	}
	if len(projects) != 1 || projects[0].ID != projectID {
		t.Fatalf("expected the new project to be stored, got %d projects", len(projects))
	}
}

func TestSyncIntegration_AcceptsMixedBatchAndExternalReference(t *testing.T) {
	// Half the references ship in the batch, half pre-exist. The external one
	// must still be validated against the database.
	svc, pool, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	existing := seedProject(t, pool, alice)
	inBatch := uuid.New()

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{projectChange(inBatch)},
			Notes: []Note{
				noteChange(uuid.New(), &inBatch),
				noteChange(uuid.New(), &existing),
			},
		},
	}); err != nil {
		t.Fatalf("mixed batch should succeed: %v", err)
	}
}

func TestSyncIntegration_RejectsCrossUserProjectID(t *testing.T) {
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsProject := seedProject(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		ClientCursor: 0,
		Changes:      SyncChanges{Projects: []Project{projectChange(bobsProject)}},
	})

	var conflict *OwnershipConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected OwnershipConflictError, got %v", err)
	}
	if len(conflict.IDs) != 1 || conflict.IDs[0] != bobsProject {
		t.Fatalf("expected Bob's project id to be reported, got %v", conflict.IDs)
	}
}

func TestSyncIntegration_SilentNoOpIsGone(t *testing.T) {
	// The upsert guard `WHERE user_id = EXCLUDED.user_id` made a cross-user id
	// a successful no-op. Verify Bob's row is genuinely untouched afterwards.
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsProject := seedProject(t, pool, bob)
	original := projectContent(t, pool, bobsProject)

	if _, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Projects: []Project{projectChange(bobsProject)}},
	}); err == nil {
		t.Fatal("expected the push to be rejected, got success")
	}

	if after := projectContent(t, pool, bobsProject); string(after) != string(original) {
		t.Fatalf("Bob's project was modified by Alice's push: %q -> %q", original, after)
	}
}

func TestSyncIntegration_RejectsNoteReferencingCrossUserProject(t *testing.T) {
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsProject := seedProject(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Notes: []Note{noteChange(uuid.New(), &bobsProject)}},
	})

	var refErr *ProjectReferenceError
	if !errors.As(err, &refErr) {
		t.Fatalf("expected ProjectReferenceError, got %v", err)
	}
}

func TestSyncIntegration_RejectsNoteReferencingProjectInSameBatchOwnedElsewhere(t *testing.T) {
	// A project in the batch clears step 2 only if it is genuinely the user's;
	// pushing Bob's id together with a note referencing it must still fail.
	svc, pool, alice, bob := newIntegrationService(t)
	ctx := context.Background()

	bobsProject := seedProject(t, pool, bob)

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{
			Projects: []Project{projectChange(bobsProject)},
			Notes:    []Note{noteChange(uuid.New(), &bobsProject)},
		},
	})

	var conflict *OwnershipConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected OwnershipConflictError from the batch project, got %v", err)
	}
}

func TestSyncIntegration_RejectsDuplicateIDsInBatch(t *testing.T) {
	svc, _, alice, _ := newIntegrationService(t)
	ctx := context.Background()

	change := projectChange(uuid.New())

	_, err := svc.Sync(ctx, alice, SyncPayload{
		Changes: SyncChanges{Projects: []Project{change, change}},
	})

	var dupErr *DuplicateEntityIDsError
	if !errors.As(err, &dupErr) {
		t.Fatalf("expected DuplicateEntityIDsError, got %v", err)
	}
}
