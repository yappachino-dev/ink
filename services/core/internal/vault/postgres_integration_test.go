package vault

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/database/dbtest"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

func fixtures(t *testing.T) (*VaultService, *PostgresVaultRepository, *store.Queries) {
	t.Helper()
	pool := dbtest.StartPostgres(t)
	q := store.New(pool)
	repo := NewPostgresVaultRepository(q)
	svc := NewVaultService(database.NewPgTransactor(pool), repo)
	return svc, repo, q
}

func seedVaultUser(t *testing.T, q *store.Queries) int {
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

func TestKeySlotsRoundTrip(t *testing.T) {
	_, repo, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	slots, err := repo.GetKeySlotsByUserID(ctx, userID)
	if err != nil || len(slots) != 0 {
		t.Fatalf("unknown user should have no slots: %v, %v", slots, err)
	}

	in := []KeySlot{
		{Type: 1, Salt: []byte("salt-1"), WrappedMasterKey: []byte("wmk-1")},
		{Type: 3, Salt: []byte("salt-3"), WrappedMasterKey: []byte("wmk-3")},
	}
	for i := range in {
		in[i].UpdatedAt = time.Now().UTC()
	}
	if err := repo.UpsertKeySlots(ctx, userID, in); err != nil {
		t.Fatalf("upsert: %v", err)
	}

	out, err := repo.GetKeySlotsByUserID(ctx, userID)
	if err != nil || len(out) != 2 {
		t.Fatalf("expected 2 slots: %v, %v", out, err)
	}
	byType := map[int]KeySlot{out[0].Type: out[0], out[1].Type: out[1]}
	for _, want := range in {
		got := byType[want.Type]
		if string(got.Salt) != string(want.Salt) || string(got.WrappedMasterKey) != string(want.WrappedMasterKey) {
			t.Fatalf("slot type %d corrupted: %+v", want.Type, got)
		}
		if got.UpdatedAt.IsZero() {
			t.Fatalf("slot type %d missing updated_at", want.Type)
		}
	}
}

func TestSaveKeySlotsAtomic(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	now := time.Now().UTC()
	slots := []KeySlot{
		{Type: 1, Salt: []byte("salt"), WrappedMasterKey: []byte("wmk"), UpdatedAt: now},
		{Type: 2, Salt: []byte("salt2"), WrappedMasterKey: []byte("wmk2"), UpdatedAt: now},
	}
	if err := svc.SaveKeySlots(ctx, userID, slots); err != nil {
		t.Fatalf("save: %v", err)
	}

	out, err := svc.GetKeys(ctx, userID)
	if err != nil || len(out) != len(slots) {
		t.Fatalf("saved slots not readable via service: %v, %v", out, err)
	}
}

// The regression this guards: setup generates a fresh master key on every run,
// so a second device pushes different key material for a key_type the account
// already holds. `ON CONFLICT (user_id, key_type) DO UPDATE` took that row
// silently and the first device could never unlock again.
func TestSaveKeySlotsRejectsDivergentSlotAgainstPostgres(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	first := []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("salt-a"), WrappedMasterKey: []byte("wmk-a"), UpdatedAt: time.Now().UTC()},
	}
	if err := svc.SaveKeySlots(ctx, userID, first); err != nil {
		t.Fatalf("first device setup: %v", err)
	}

	second := []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("salt-b"), WrappedMasterKey: []byte("wmk-b"), UpdatedAt: time.Now().UTC()},
	}
	err := svc.SaveKeySlots(ctx, userID, second)

	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected a conflict from real postgres, got %v", err)
	}

	// The stored slot must still be the first device's.
	out, err := q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		t.Fatalf("read back: %v", err)
	}
	if len(out) != 1 {
		t.Fatalf("expected 1 slot, got %d", len(out))
	}
	if string(out[0].Salt) != "salt-a" || string(out[0].WrappedMasterKey) != "wmk-a" {
		t.Fatalf("divergent slot overwrote the stored one: %+v", out[0])
	}
}

// A rejected batch must not partially apply, or the account ends up holding a
// mix of master keys.
func TestSaveKeySlotsRejectsWholeBatchOnPostgres(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	now := time.Now().UTC()
	if err := svc.SaveKeySlots(ctx, userID, []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("salt-a"), WrappedMasterKey: []byte("wmk-a"), UpdatedAt: now},
	}); err != nil {
		t.Fatalf("setup: %v", err)
	}

	// Type 1 diverges from what is stored, type 2 is new and harmless.
	err := svc.SaveKeySlots(ctx, userID, []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("salt-b"), WrappedMasterKey: []byte("wmk-b"), UpdatedAt: now},
		{Type: KeyTypePattern, Salt: []byte("salt-p"), WrappedMasterKey: []byte("wmk-p"), UpdatedAt: now},
	})
	if err == nil {
		t.Fatal("expected the batch to be rejected")
	}

	out, err := q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		t.Fatalf("read back: %v", err)
	}
	if len(out) != 1 {
		t.Fatalf("the harmless slot must not land when the batch is rejected, got %d slots", len(out))
	}
}

// The client re-pushes pending slots after a lost response, so an identical
// push must still succeed against a real database.
func TestSaveKeySlotsIdempotentRetryAgainstPostgres(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	slots := []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("salt-a"), WrappedMasterKey: []byte("wmk-a"), UpdatedAt: time.Now().UTC()},
	}
	if err := svc.SaveKeySlots(ctx, userID, slots); err != nil {
		t.Fatalf("first push: %v", err)
	}
	if err := svc.SaveKeySlots(ctx, userID, slots); err != nil {
		t.Fatalf("identical retry must be accepted against postgres: %v", err)
	}
}
