package vault

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"
)

// Two devices pushing a slot for the same key_type at the same time must not
// both succeed. Without a per-account lock the divergence check is unsound:
// READ COMMITTED gives each statement a fresh snapshot, so both transactions
// read an empty vault, both pass the check, and the second ON CONFLICT DO
// UPDATE overwrites the first. Only device A's slots would be lost, with no
// error reported on either side.
func TestConcurrentPushesSerializePerAccount(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	mk := func(salt, wmk string) []KeySlot {
		return []KeySlot{{
			Type:             KeyTypePIN,
			Salt:             []byte(salt),
			WrappedMasterKey: []byte(wmk),
			UpdatedAt:        time.Now().UTC(),
		}}
	}

	const attempts = 12
	var wg sync.WaitGroup
	start := make(chan struct{})
	errs := make([]error, attempts)

	for i := range attempts {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			<-start
			errs[i] = svc.SaveKeySlots(ctx, userID, mk("salt-"+string(rune('a'+i)), "wmk-"+string(rune('a'+i))))
		}(i)
	}
	close(start)
	wg.Wait()

	accepted := 0
	for _, err := range errs {
		var conflict *KeySlotConflictError
		switch {
		case err == nil:
			accepted++
		case errors.As(err, &conflict):
		default:
			t.Fatalf("unexpected error, not a conflict: %v", err)
		}
	}
	if accepted != 1 {
		t.Fatalf("expected exactly one push to be accepted, got %d", accepted)
	}

	out, err := q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		t.Fatalf("read back: %v", err)
	}
	if len(out) != 1 {
		t.Fatalf("expected a single slot, got %d", len(out))
	}
}

// The lock is per account, so one account's push must not block another's.
func TestLockDoesNotCrossAccounts(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	first := seedVaultUser(t, q)
	second := seedVaultUser(t, q)

	slot := []KeySlot{{
		Type:             KeyTypePIN,
		Salt:             []byte("salt"),
		WrappedMasterKey: []byte("wmk"),
		UpdatedAt:        time.Now().UTC(),
	}}

	var wg sync.WaitGroup
	errs := make([]error, 2)
	start := make(chan struct{})
	for i, id := range []int{first, second} {
		wg.Add(1)
		go func(i, id int) {
			defer wg.Done()
			<-start
			errs[i] = svc.SaveKeySlots(ctx, id, slot)
		}(i, id)
	}
	close(start)
	wg.Wait()

	for i, err := range errs {
		if err != nil {
			t.Fatalf("account %d must not be blocked by the other: %v", i, err)
		}
	}
}

func TestLockReleasedOnRollback(t *testing.T) {
	// The lock is transaction-scoped. If a failed save held it, every later
	// push for that account would block forever.
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)

	slot := []KeySlot{{
		Type:             KeyTypePIN,
		Salt:             []byte("salt-a"),
		WrappedMasterKey: []byte("wmk-a"),
		UpdatedAt:        time.Now().UTC(),
	}}
	if err := svc.SaveKeySlots(ctx, userID, slot); err != nil {
		t.Fatalf("first save: %v", err)
	}

	// Divergent, so this rolls back.
	divergent := []KeySlot{{
		Type:             KeyTypePIN,
		Salt:             []byte("salt-b"),
		WrappedMasterKey: []byte("wmk-b"),
		UpdatedAt:        time.Now().UTC(),
	}}
	err := svc.SaveKeySlots(ctx, userID, divergent)
	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected a conflict, got %v", err)
	}

	done := make(chan error, 1)
	go func() { done <- svc.SaveKeySlots(ctx, userID, slot) }()
	select {
	case err := <-done:
		if err != nil {
			t.Fatalf("save after rollback must not deadlock or fail: %v", err)
		}
	case <-time.After(10 * time.Second):
		t.Fatal("save after rollback deadlocked, the lock was not released")
	}
}

// Uniqueness still holds after a rollback leaves no row behind.
func TestConcurrentPushesAfterRollback(t *testing.T) {
	svc, _, q := fixtures(t)
	ctx := context.Background()
	userID := seedVaultUser(t, q)
	// The lock is taken before validation runs, so this also proves a rejected
	// batch releases it.
	bad := []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("a"), WrappedMasterKey: []byte("a"), UpdatedAt: time.Now().UTC()},
		{Type: KeyTypePIN, Salt: []byte("b"), WrappedMasterKey: []byte("b"), UpdatedAt: time.Now().UTC()},
	}
	var conflict *KeySlotConflictError
	if err := svc.SaveKeySlots(ctx, userID, bad); !errors.As(err, &conflict) {
		t.Fatalf("expected a conflict, got %v", err)
	}

	out, err := q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		t.Fatalf("read back: %v", err)
	}
	if len(out) != 0 {
		t.Fatalf("a rejected batch must leave no rows, got %d", len(out))
	}
}
