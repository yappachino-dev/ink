package auth

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/yappachino-dev/ink/services/core/internal/database/dbtest"
	"github.com/yappachino-dev/ink/services/core/internal/store"
)

func newRepos(t *testing.T) (*PostgresUserRepository, *PostgresTokenRepository, *PostgresVerificationRepository) {
	t.Helper()
	pool := dbtest.StartPostgres(t)
	q := store.New(pool)
	return NewPostgresUserRepository(q), NewPostgresTokenRepository(q), NewPostgresVerificationRepository(q)
}

func TestUserRepositoryRoundTrip(t *testing.T) {
	users, _, _ := newRepos(t)
	ctx := context.Background()

	u := &User{Email: "alice@example.com", PasswordHash: "hash"}
	if err := users.Create(ctx, u); err != nil {
		t.Fatalf("create: %v", err)
	}
	if u.ID == 0 {
		t.Fatal("expected ID to be populated")
	}
	if u.CreatedAt.IsZero() || u.UpdatedAt.IsZero() {
		t.Fatal("expected timestamps to be populated")
	}

	got, err := users.ByEmail(ctx, "alice@example.com")
	if err != nil || got == nil {
		t.Fatalf("by email: %v, %v", got, err)
	}
	if got.ID != u.ID || got.SyncCursor != 0 {
		t.Fatalf("unexpected user: %+v", got)
	}

	got, err = users.ByID(ctx, u.ID)
	if err != nil || got == nil || got.Email != "alice@example.com" {
		t.Fatalf("by id: %v, %v", got, err)
	}

	if got, err = users.ByEmail(ctx, "nobody@example.com"); got != nil || err != nil {
		t.Fatalf("unknown email should return nil,nil; got %v, %v", got, err)
	}
}

func TestUserRepositoryDuplicateEmailMapsToDomainError(t *testing.T) {
	users, _, _ := newRepos(t)
	ctx := context.Background()

	if err := users.Create(ctx, &User{Email: "dup@example.com", PasswordHash: "h"}); err != nil {
		t.Fatalf("first create: %v", err)
	}
	err := users.Create(ctx, &User{Email: "dup@example.com", PasswordHash: "h"})
	if err != ErrUserAlreadyExists {
		t.Fatalf("duplicate email must surface ErrUserAlreadyExists, got %v", err)
	}
}

func TestTokenRepositoryLifecycle(t *testing.T) {
	users, tokens, _ := newRepos(t)
	ctx := context.Background()

	u := &User{Email: "bob@example.com", PasswordHash: "hash"}
	if err := users.Create(ctx, u); err != nil {
		t.Fatalf("create user: %v", err)
	}

	hash := []byte(uuid.NewString())
	rt := &RefreshToken{
		UserID:    u.ID,
		Hash:      hash,
		ExpiresAt: time.Now().UTC().Add(time.Hour),
	}
	if err := tokens.Create(ctx, rt); err != nil {
		t.Fatalf("create token: %v", err)
	}
	if rt.CreatedAt.IsZero() {
		t.Fatal("expected created_at to be populated")
	}
	if !rt.RevokedAt.IsZero() {
		t.Fatal("fresh token must not be revoked")
	}

	got, err := tokens.ByHash(ctx, hash)
	if err != nil || got == nil {
		t.Fatalf("by hash: %v, %v", got, err)
	}
	if got.RevokedAt != (time.Time{}) {
		t.Fatalf("expected zero revoked_at, got %v", got.RevokedAt)
	}

	// Revoke and confirm the timestamp lands.
	if err := tokens.RevokeByHash(ctx, hash); err != nil {
		t.Fatalf("revoke: %v", err)
	}
	got, err = tokens.ByHash(ctx, hash)
	if err != nil || got == nil {
		t.Fatalf("by hash after revoke: %v, %v", got, err)
	}
	if got.RevokedAt.IsZero() {
		t.Fatal("revoked_at should be set after revoke")
	}

	// Revoke-all sweep.
	hash2 := []byte(uuid.NewString())
	if err := tokens.Create(ctx, &RefreshToken{
		UserID:    u.ID,
		Hash:      hash2,
		ExpiresAt: time.Now().UTC().Add(time.Hour),
	}); err != nil {
		t.Fatalf("create second token: %v", err)
	}
	if err := tokens.RevokeAllByUserID(ctx, u.ID); err != nil {
		t.Fatalf("revoke all: %v", err)
	}
	got, _ = tokens.ByHash(ctx, hash2)
	if got == nil || got.RevokedAt.IsZero() {
		t.Fatal("second token should be revoked by revoke-all")
	}
}

func TestTokenRepositoryUpdate(t *testing.T) {
	users, tokens, _ := newRepos(t)
	ctx := context.Background()

	u := &User{Email: "carol@example.com", PasswordHash: "hash"}
	if err := users.Create(ctx, u); err != nil {
		t.Fatalf("create user: %v", err)
	}

	hash := []byte(uuid.NewString())
	rt := &RefreshToken{
		UserID:    u.ID,
		Hash:      hash,
		ExpiresAt: time.Now().UTC().Add(2 * time.Hour),
	}
	if err := tokens.Create(ctx, rt); err != nil {
		t.Fatalf("create: %v", err)
	}

	newExpiry := time.Now().UTC().Add(4 * time.Hour)
	revokeAt := time.Now().UTC()
	rt.Hash = []byte(uuid.NewString())
	rt.ExpiresAt = newExpiry
	rt.RevokedAt = revokeAt
	if err := tokens.Update(ctx, rt); err != nil {
		t.Fatalf("update: %v", err)
	}

	got, err := tokens.ByHash(ctx, rt.Hash)
	if err != nil || got == nil {
		t.Fatalf("by updated hash: %v, %v", got, err)
	}
	if got.RevokedAt.IsZero() {
		t.Fatal("revoked_at should survive update")
	}
	if diff := got.ExpiresAt.Sub(newExpiry); diff < -time.Minute || diff > time.Minute {
		t.Fatalf("expiry not persisted as written: %v vs %v", got.ExpiresAt, newExpiry)
	}
}

func TestVerificationRepositoryLifecycle(t *testing.T) {
	_, _, verifs := newRepos(t)
	ctx := context.Background()

	email := "dave@example.com"
	codeHash := []byte("code-hash")
	if err := verifs.Create(ctx, email, codeHash); err != nil {
		t.Fatalf("create: %v", err)
	}

	v, err := verifs.LatestByEmail(ctx, email)
	if err != nil || v == nil {
		t.Fatalf("latest: %v, %v", v, err)
	}
	if string(v.CodeHash) != string(codeHash) {
		t.Fatalf("code hash mismatch: %s", v.CodeHash)
	}
	if v.UsedAt != (time.Time{}) {
		t.Fatal("fresh verification must not be used")
	}
	if !v.ExpiresAt.After(v.CreatedAt.Add(5 * time.Minute)) {
		t.Fatalf("expected ~10min expiry window, created=%v expires=%v", v.CreatedAt, v.ExpiresAt)
	}

	if err := verifs.MarkAsUsed(ctx, v.ID); err != nil {
		t.Fatalf("mark used: %v", err)
	}
	v, _ = verifs.LatestByEmail(ctx, email)
	if v.UsedAt.IsZero() {
		t.Fatal("used_at should be set after MarkAsUsed")
	}

	// MarkAllAsUsed covers every outstanding row for the email.
	if err := verifs.Create(ctx, email, []byte("second")); err != nil {
		t.Fatalf("create second: %v", err)
	}
	if err := verifs.MarkAllAsUsed(ctx, email); err != nil {
		t.Fatalf("mark all: %v", err)
	}
	v, _ = verifs.LatestByEmail(ctx, email)
	if v.UsedAt.IsZero() {
		t.Fatal("latest verification should be marked used")
	}
}
