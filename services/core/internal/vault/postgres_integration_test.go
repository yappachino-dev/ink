package vault

import (
	"context"
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
