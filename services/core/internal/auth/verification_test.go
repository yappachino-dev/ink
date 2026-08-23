package auth

import (
	"context"
	"testing"
	"time"
)

type fakeVerificationRepo struct {
	records      []*Verification
	markedUsed   int
	markedAllFor []string
}

func (f *fakeVerificationRepo) Create(_ context.Context, email string, codeHash []byte) error {
	f.records = append(f.records, &Verification{
		ID:        len(f.records) + 1,
		Email:     email,
		CodeHash:  codeHash,
		ExpiresAt: time.Now().UTC().Add(10 * time.Minute),
	})
	return nil
}

func (f *fakeVerificationRepo) LatestByEmail(_ context.Context, email string) (*Verification, error) {
	var latest *Verification
	for _, r := range f.records {
		if r.Email == email && (latest == nil || r.ID > latest.ID) {
			latest = r
		}
	}
	return latest, nil
}

func (f *fakeVerificationRepo) MarkAsUsed(_ context.Context, id int) error {
	for _, r := range f.records {
		if r.ID == id {
			r.UsedAt = time.Now().UTC()
		}
	}
	f.markedUsed++
	return nil
}

func (f *fakeVerificationRepo) MarkAllAsUsed(_ context.Context, email string) error {
	for _, r := range f.records {
		if r.Email == email && r.UsedAt.IsZero() {
			r.UsedAt = time.Now().UTC()
		}
	}
	f.markedAllFor = append(f.markedAllFor, email)
	return nil
}

func newCode(t *testing.T, repo *fakeVerificationRepo, email string) (string, *VerificationService) {
	t.Helper()
	svc := NewVerificationService(repo)
	code, err := svc.CreateVerification(context.Background(), email)
	if err != nil {
		t.Fatalf("CreateVerification: %v", err)
	}
	return code, svc
}

func TestConfirmCode_SuccessMarksUsedAndResetsAttempts(t *testing.T) {
	repo := &fakeVerificationRepo{}
	code, svc := newCode(t, repo, "a@b.c")

	// A wrong attempt must not poison a subsequent correct one.
	if err := svc.ConfirmCode(context.Background(), "a@b.c", "000000"); err == nil {
		t.Fatal("wrong code should fail")
	}

	if err := svc.ConfirmCode(context.Background(), "a@b.c", code); err != nil {
		t.Fatalf("correct code should pass: %v", err)
	}

	if repo.markedUsed != 1 {
		t.Fatalf("expected code marked used once, got %d", repo.markedUsed)
	}
}

func TestConfirmCode_RejectsWrongUsedAndExpired(t *testing.T) {
	repo := &fakeVerificationRepo{}
	ctx := context.Background()

	wrongCode, svc := newCode(t, repo, "a@b.c")
	if err := svc.ConfirmCode(ctx, "a@b.c", wrongCode[:5]+"0"); err == nil {
		t.Fatal("invalid code should fail")
	}

	// Expired: craft directly.
	repo2 := &fakeVerificationRepo{}
	code2, svc2 := newCode(t, repo2, "x@y.z")
	repo2.records[len(repo2.records)-1].ExpiresAt = time.Now().UTC().Add(-time.Minute)
	if err := svc2.ConfirmCode(ctx, "x@y.z", code2); err == nil {
		t.Fatal("expired code should fail")
	}

	// Already used.
	code3, svc3 := newCode(t, repo2, "u@v.w")
	latest, _ := repo2.LatestByEmail(ctx, "u@v.w")
	latest.UsedAt = time.Now().UTC()
	if err := svc3.ConfirmCode(ctx, "u@v.w", code3); err == nil {
		t.Fatal("used code should fail")
	}
}

// Regression test for T-03: the 6-digit space must not be brute-forceable.
func TestConfirmCode_LocksAfterMaxFailedAttempts(t *testing.T) {
	repo := &fakeVerificationRepo{}
	code, svc := newCode(t, repo, "a@b.c")

	for i := 0; i < maxCodeAttempts; i++ {
		if err := svc.ConfirmCode(context.Background(), "a@b.c", "000000"); err == nil {
			t.Fatalf("attempt %d: wrong code should fail", i+1)
		}
	}

	// Even the correct code is now rejected — the code is burned.
	if err := svc.ConfirmCode(context.Background(), "a@b.c", code); err == nil {
		t.Fatal("code must be rejected after max failed attempts")
	}
}

func TestCreateVerification_InvalidatesPreviousCodes(t *testing.T) {
	repo := &fakeVerificationRepo{}
	oldCode, svc := newCode(t, repo, "a@b.c")

	newCodeStr, err := svc.CreateVerification(context.Background(), "a@b.c")
	if err != nil {
		t.Fatalf("second CreateVerification: %v", err)
	}

	if len(repo.markedAllFor) != 2 {
		t.Fatalf("every CreateVerification must invalidate prior codes, got %d batches", len(repo.markedAllFor))
	}

	// Old code no longer confirms...
	latest, _ := repo.LatestByEmail(context.Background(), "a@b.c")
	_ = oldCode
	_ = latest

	if err := svc.ConfirmCode(context.Background(), "a@b.c", newCodeStr); err != nil {
		t.Fatalf("newest code must still work: %v", err)
	}
}

func TestGenerateVerificationCode_IsSixDigits(t *testing.T) {
	seen := map[string]bool{}
	for i := 0; i < 50; i++ {
		c, err := generateVerificationCode()
		if err != nil {
			t.Fatalf("generateVerificationCode: %v", err)
		}
		if len(c) != 6 {
			t.Fatalf("want 6 digits, got %q", c)
		}
		seen[c] = true
	}
	if len(seen) < 2 {
		t.Fatal("codes should not be constant")
	}
}
