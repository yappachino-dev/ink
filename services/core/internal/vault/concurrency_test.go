package vault

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/yappachino-dev/ink/services/core/internal/database"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

const (
	concurrentAttempts = 12
	concurrentPoolSize = 24
)

// sizedPool boots a Postgres whose pool is sized explicitly.
//
// dbtest.StartPostgres uses pgxpool.New, whose MaxConns defaults to
// max(4, NumCPU). These tests hold a connection for a whole transaction, so
// running more concurrent transactions than the pool allows starves it: the
// surplus goroutines wait for a connection that is only freed once the
// transaction holding it commits, and those transactions are themselves
// waiting on the advisory lock. On a 2-core CI runner that is a deadlock, and
// it hung until the 10-minute package timeout. An explicit size makes these
// tests independent of the machine they run on.
func sizedPool(t *testing.T, maxConns int32) *pgxpool.Pool {
	t.Helper()

	ctx := context.Background()
	ctr, err := postgres.Run(ctx,
		"postgres:18-alpine",
		postgres.WithDatabase("data"),
		postgres.WithUsername("postgres"),
		postgres.WithPassword("postgres"),
		postgres.BasicWaitStrategies(),
	)
	if err != nil {
		t.Fatalf("start postgres: %v", err)
	}
	t.Cleanup(func() { _ = ctr.Terminate(ctx) })

	dsn, err := ctr.ConnectionString(ctx)
	if err != nil {
		t.Fatalf("connection string: %v", err)
	}

	config, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		t.Fatalf("parse pool config: %v", err)
	}
	config.MaxConns = maxConns

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		t.Fatalf("connect pool: %v", err)
	}
	t.Cleanup(pool.Close)

	connCfg, err := pgx.ParseConfig(dsn)
	if err != nil {
		t.Fatalf("parse conn config: %v", err)
	}
	sqlDB := stdlib.OpenDB(*connCfg)
	defer sqlDB.Close()
	if err := database.Migrate(ctx, sqlDB); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}

	return pool
}

func concurrencyFixtures(t *testing.T) (*VaultService, *store.Queries, *pgxpool.Pool) {
	t.Helper()
	pool := sizedPool(t, concurrentPoolSize)
	q := store.New(pool)
	return NewVaultService(database.NewPgTransactor(pool), NewPostgresVaultRepository(q)), q, pool
}

// testContext bounds every save in this file. Without it a regression that
// reintroduces a deadlock burns the whole 10-minute package timeout before
// reporting anything useful.
func testContext(t *testing.T) context.Context {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	t.Cleanup(cancel)
	return ctx
}

func pinSlot(salt, wmk string) []KeySlot {
	return []KeySlot{{
		Type:             KeyTypePIN,
		Salt:             []byte(salt),
		WrappedMasterKey: []byte(wmk),
		UpdatedAt:        time.Now().UTC(),
	}}
}

// TestLockSerializesSavesForOneAccount is the deterministic guard.
//
// The many-goroutine test below cannot serve as the guard: the window between
// the read and the upsert is microseconds wide, so with the lock removed it
// passes often enough to be useless. Here the lock is taken explicitly in one
// transaction and a real save is asserted to block behind it, which is exact
// and independent of scheduling.
func TestLockSerializesSavesForOneAccount(t *testing.T) {
	svc, q, pool := concurrencyFixtures(t)
	ctx := testContext(t)
	userID := seedVaultUser(t, q)

	// Same advisory lock a save takes, held by a transaction that stays open.
	holder, err := pool.Begin(ctx)
	if err != nil {
		t.Fatalf("begin holder: %v", err)
	}
	defer func() { _ = holder.Rollback(ctx) }()

	if _, err := holder.Exec(ctx, "SELECT pg_advisory_xact_lock(78511, $1)", userID); err != nil {
		t.Fatalf("take advisory lock: %v", err)
	}

	done := make(chan error, 1)
	go func() { done <- svc.SaveKeySlots(ctx, userID, pinSlot("salt-a", "wmk-a")) }()

	select {
	case err := <-done:
		t.Fatalf("save returned while the account lock was held elsewhere: %v", err)
	case <-time.After(750 * time.Millisecond):
		// Still blocked, which is the point.
	}

	if err := holder.Rollback(ctx); err != nil {
		t.Fatalf("release lock: %v", err)
	}

	select {
	case err := <-done:
		if err != nil {
			t.Fatalf("save after the lock was released: %v", err)
		}
	case <-time.After(10 * time.Second):
		t.Fatal("save did not proceed after the lock was released")
	}
}

// A different account must not be blocked by another's lock.
func TestLockDoesNotCrossAccounts(t *testing.T) {
	svc, q, pool := concurrencyFixtures(t)
	ctx := testContext(t)
	first := seedVaultUser(t, q)
	second := seedVaultUser(t, q)

	holder, err := pool.Begin(ctx)
	if err != nil {
		t.Fatalf("begin holder: %v", err)
	}
	defer func() { _ = holder.Rollback(ctx) }()
	if _, err := holder.Exec(ctx, "SELECT pg_advisory_xact_lock(78511, $1)", first); err != nil {
		t.Fatalf("take advisory lock: %v", err)
	}

	done := make(chan error, 1)
	go func() { done <- svc.SaveKeySlots(ctx, second, pinSlot("salt", "wmk")) }()

	select {
	case err := <-done:
		if err != nil {
			t.Fatalf("the second account must not be blocked: %v", err)
		}
	case <-time.After(10 * time.Second):
		t.Fatal("the lock leaked across accounts")
	}
}

// Many simultaneous pushes for one account must leave exactly one slot and
// report every loser as a conflict, never as a silent overwrite.
func TestConcurrentPushesSerializePerAccount(t *testing.T) {
	svc, q, _ := concurrencyFixtures(t)
	ctx := testContext(t)
	userID := seedVaultUser(t, q)

	var wg sync.WaitGroup
	start := make(chan struct{})
	errs := make([]error, concurrentAttempts)

	for i := range concurrentAttempts {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			<-start
			errs[i] = svc.SaveKeySlots(ctx, userID,
				pinSlot("salt-"+string(rune('a'+i)), "wmk-"+string(rune('a'+i))))
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

// The lock is transaction-scoped. If a failed save held it, every later push
// for that account would block until the connection died.
func TestLockReleasedOnRollback(t *testing.T) {
	svc, q, _ := concurrencyFixtures(t)
	ctx := testContext(t)
	userID := seedVaultUser(t, q)

	first := pinSlot("salt-a", "wmk-a")
	if err := svc.SaveKeySlots(ctx, userID, first); err != nil {
		t.Fatalf("first save: %v", err)
	}

	// Divergent, so this rolls back.
	err := svc.SaveKeySlots(ctx, userID, pinSlot("salt-b", "wmk-b"))
	var conflict *KeySlotConflictError
	if !errors.As(err, &conflict) {
		t.Fatalf("expected a conflict, got %v", err)
	}

	if err := svc.SaveKeySlots(ctx, userID, first); err != nil {
		t.Fatalf("save after rollback must not deadlock or fail: %v", err)
	}
}

// The lock is taken before validation runs, so a rejected batch releases it and
// leaves no row behind.
func TestRejectedBatchReleasesLockAndWritesNothing(t *testing.T) {
	svc, q, _ := concurrencyFixtures(t)
	ctx := testContext(t)
	userID := seedVaultUser(t, q)

	duplicateType := []KeySlot{
		{Type: KeyTypePIN, Salt: []byte("a"), WrappedMasterKey: []byte("a"), UpdatedAt: time.Now().UTC()},
		{Type: KeyTypePIN, Salt: []byte("b"), WrappedMasterKey: []byte("b"), UpdatedAt: time.Now().UTC()},
	}
	var conflict *KeySlotConflictError
	if err := svc.SaveKeySlots(ctx, userID, duplicateType); !errors.As(err, &conflict) {
		t.Fatalf("expected a conflict, got %v", err)
	}

	out, err := q.GetKeySlotsByUserID(ctx, int32(userID))
	if err != nil {
		t.Fatalf("read back: %v", err)
	}
	if len(out) != 0 {
		t.Fatalf("a rejected batch must leave no rows, got %d", len(out))
	}

	if err := svc.SaveKeySlots(ctx, userID, pinSlot("salt-a", "wmk-a")); err != nil {
		t.Fatalf("the account must still be usable: %v", err)
	}
}
