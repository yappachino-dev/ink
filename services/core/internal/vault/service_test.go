package vault

import (
	"context"
	"errors"
	"testing"
)

type stubRepo struct {
	stored      []KeySlot
	saved       []KeySlot
	saveCalls   int
	getCalls    int
	getWasInTx  bool
	saveWasInTx bool
	lockWasInTx bool
	lockCalls   int
	order       []string
	getErr      error
	lockErr     error
}

func (r *stubRepo) GetKeySlotsByUserID(ctx context.Context, _ int) ([]KeySlot, error) {
	r.getCalls++
	r.getWasInTx = inTransaction(ctx)
	r.order = append(r.order, "read")
	return r.stored, r.getErr
}

func (r *stubRepo) UpsertKeySlots(ctx context.Context, _ int, keySlots []KeySlot) error {
	r.saveCalls++
	r.saveWasInTx = inTransaction(ctx)
	r.order = append(r.order, "write")
	r.saved = keySlots
	return nil
}

// Records ordering, so a test can assert the lock precedes the read rather than
// merely happening somewhere in the transaction.
func (r *stubRepo) LockKeySlotsForUpdate(ctx context.Context, _ int) error {
	r.lockCalls++
	r.lockWasInTx = inTransaction(ctx)
	r.order = append(r.order, "lock")
	return r.lockErr
}

type stubTransactor struct {
	called bool
}

type txMarker struct{}

// The stub marks the context the way PgTransactor does, so a test can tell a
// transactional read from one that escaped to the pool.
func (t *stubTransactor) WithinTransaction(ctx context.Context, fn func(context.Context) error) error {
	t.called = true
	return fn(context.WithValue(ctx, txMarker{}, true))
}

func inTransaction(ctx context.Context) bool {
	marked, _ := ctx.Value(txMarker{}).(bool)
	return marked
}

func slot(keyType int, salt, wmk string) KeySlot {
	return KeySlot{
		UserID:           1,
		Type:             keyType,
		Salt:             []byte(salt),
		WrappedMasterKey: []byte(wmk),
	}
}

func TestSaveKeySlotsRejectsDivergentSlot(t *testing.T) {
	// The regression: a second device runs setup, generates a fresh master
	// key, and pushes a different wrapped key for a type the account already
	// has. Before this check the upsert took it silently and the first device
	// could never unlock again.
	repo := &stubRepo{stored: []KeySlot{slot(KeyTypePIN, "salt-a", "wmk-a")}}
	svc := NewVaultService(&stubTransactor{}, repo)

	err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-b", "wmk-b"),
	})

	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected KeySlotConflictError, got %v", err)
	}
	if conflict.KeyType != KeyTypePIN {
		t.Fatalf("expected the conflicting PIN type, got %d", conflict.KeyType)
	}
	if repo.saveCalls != 0 {
		t.Fatalf("rejected batch must not be written, got %d save calls", repo.saveCalls)
	}
}

func TestSaveKeySlotsAllowsIdenticalRetry(t *testing.T) {
	// The client re-pushes pending slots after a lost response. Rejecting a
	// byte-identical retry would strand the slot as pending forever.
	stored := slot(KeyTypePIN, "salt-a", "wmk-a")
	repo := &stubRepo{stored: []KeySlot{stored}}
	svc := NewVaultService(&stubTransactor{}, repo)

	if err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{stored}); err != nil {
		t.Fatalf("identical retry must be accepted, got %v", err)
	}
	if repo.saveCalls != 1 {
		t.Fatalf("expected the retry to be written, got %d save calls", repo.saveCalls)
	}
}

func TestSaveKeySlotsAllowsNewTypeOnExistingVault(t *testing.T) {
	// Adding a PIN to a vault that only has a recovery slot is the normal
	// case, not a conflict.
	repo := &stubRepo{stored: []KeySlot{slot(KeyTypeRecovery, "salt-r", "wmk-r")}}
	svc := NewVaultService(&stubTransactor{}, repo)

	if err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-p", "wmk-p"),
	}); err != nil {
		t.Fatalf("adding a new key type must be accepted, got %v", err)
	}
	if repo.saveCalls != 1 {
		t.Fatalf("expected the new slot to be written, got %d save calls", repo.saveCalls)
	}
}

func TestSaveKeySlotsAllowsFreshVault(t *testing.T) {
	repo := &stubRepo{}
	svc := NewVaultService(&stubTransactor{}, repo)

	if err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-p", "wmk-p"),
		slot(KeyTypeRecovery, "salt-r", "wmk-r"),
	}); err != nil {
		t.Fatalf("first setup must be accepted, got %v", err)
	}
}

func TestSaveKeySlotsRejectsDuplicateTypeInBatch(t *testing.T) {
	// Two slots of one type resolve by last-write-wins inside the upsert, so
	// the surviving row is not necessarily the one the client sent.
	repo := &stubRepo{}
	svc := NewVaultService(&stubTransactor{}, repo)

	err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-a", "wmk-a"),
		slot(KeyTypePIN, "salt-b", "wmk-b"),
	})

	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected KeySlotConflictError for a duplicated type, got %v", err)
	}
	if repo.saveCalls != 0 {
		t.Fatalf("rejected batch must not be written, got %d save calls", repo.saveCalls)
	}
}

func TestSaveKeySlotsRejectsSaltOnlyDivergence(t *testing.T) {
	// A different salt changes the derived KEK, so the stored wrapped key no
	// longer decrypts. Comparing only the wrapped key would let this through.
	repo := &stubRepo{stored: []KeySlot{slot(KeyTypePIN, "salt-a", "wmk-a")}}
	svc := NewVaultService(&stubTransactor{}, repo)

	err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-different", "wmk-a"),
	})

	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected a salt-only change to conflict, got %v", err)
	}
}

func TestSaveKeySlotsReadsInsideTransaction(t *testing.T) {
	// Reading outside the transaction would let two concurrent pushes both
	// pass the check and the second would still overwrite the first.
	repo := &stubRepo{}
	transactor := &stubTransactor{}
	svc := NewVaultService(transactor, repo)

	if err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-a", "wmk-a"),
	}); err != nil {
		t.Fatalf("save: %v", err)
	}
	if !transactor.called {
		t.Fatal("save must run inside a transaction")
	}
	if repo.getCalls == 0 {
		t.Fatal("existing slots must be read before writing")
	}
	if !repo.getWasInTx {
		t.Fatal("existing slots must be read inside the transaction")
	}
	if !repo.saveWasInTx {
		t.Fatal("slots must be written inside the transaction")
	}
}

func TestSaveKeySlotsPropagatesReadFailure(t *testing.T) {
	// A read failure must abort rather than be treated as "no existing slots",
	// which would skip the check and overwrite blindly.
	repo := &stubRepo{getErr: errors.New("connection reset")}
	svc := NewVaultService(&stubTransactor{}, repo)

	err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{
		slot(KeyTypePIN, "salt-a", "wmk-a"),
	})

	if err == nil || err.Error() != "connection reset" {
		t.Fatalf("expected the read failure to propagate, got %v", err)
	}
	if repo.saveCalls != 0 {
		t.Fatalf("must not write after a failed read, got %d save calls", repo.saveCalls)
	}
}

func TestKeyTypeNameCoversUnknownValues(t *testing.T) {
	// A newer client may send a type this build does not know. The message
	// must still identify which slot conflicted.
	if got := keyTypeName(KeyTypeRecovery); got != "RECOVERY" {
		t.Fatalf("expected RECOVERY, got %q", got)
	}
	if got := keyTypeName(99); got != "99" {
		t.Fatalf("expected the numeric form for an unknown type, got %q", got)
	}
}

func TestSaveKeySlotsPropagatesLockFailure(t *testing.T) {
	// Proceeding without the lock would make the divergence check unsound, so
	// a failure to take it has to abort the save rather than fall through.
	repo := &stubRepo{lockErr: errors.New("advisory lock unavailable")}
	svc := NewVaultService(&stubTransactor{}, repo)

	err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{slot(KeyTypePIN, "salt-a", "wmk-a")})

	if err == nil || err.Error() != "advisory lock unavailable" {
		t.Fatalf("expected the lock failure to propagate, got %v", err)
	}
	if repo.getCalls != 0 {
		t.Fatal("must not read before the lock is held")
	}
	if repo.saveCalls != 0 {
		t.Fatalf("must not write without the lock, got %d save calls", repo.saveCalls)
	}
}

func TestSaveKeySlotsLocksBeforeReading(t *testing.T) {
	// Locking after the read reintroduces the race: a concurrent push can
	// commit between the two, and this transaction then compares against a
	// snapshot it no longer holds.
	repo := &stubRepo{}
	svc := NewVaultService(&stubTransactor{}, repo)

	if err := svc.SaveKeySlots(context.Background(), 1, []KeySlot{slot(KeyTypePIN, "salt-a", "wmk-a")}); err != nil {
		t.Fatalf("save: %v", err)
	}

	want := []string{"lock", "read", "write"}
	if len(repo.order) != len(want) {
		t.Fatalf("expected %v, got %v", want, repo.order)
	}
	for i, step := range want {
		if repo.order[i] != step {
			t.Fatalf("expected %v, got %v", want, repo.order)
		}
	}
	if !repo.lockWasInTx {
		t.Fatal("the lock must be taken inside the transaction, it is released on commit")
	}
}
