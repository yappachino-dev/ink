package auth

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type fakeUserRepo struct {
	users map[string]*User // keyed by email
}

func newFakeUserRepo() *fakeUserRepo {
	return &fakeUserRepo{users: make(map[string]*User)}
}

func (f *fakeUserRepo) Create(_ context.Context, u *User) error {
	u.ID = len(f.users) + 1
	f.users[u.Email] = u
	return nil
}

func (f *fakeUserRepo) ByEmail(_ context.Context, email string) (*User, error) {
	u, ok := f.users[email]
	if !ok {
		return nil, nil
	}
	return u, nil
}

func (f *fakeUserRepo) ByID(_ context.Context, id int) (*User, error) {
	for _, u := range f.users {
		if u.ID == id {
			return u, nil
		}
	}
	return nil, nil
}

type fakeTokenRepo struct {
	tokens    map[string]*RefreshToken // keyed by hash
	revokeAll []int
	nextID    int
	rotateErr error

	// Forces the revocation to fail, so the "we log and still deny" path can be
	// exercised. It used to be impossible to reach: this method returned nil
	// unconditionally, which is why a discarded error went unnoticed.
	revokeAllErr error

	// Cancels the caller's context from inside ByHash, after the row has been
	// found, to reproduce a client disconnecting mid-request.
	cancelOnByHash context.CancelFunc
}

func newFakeTokenRepo() *fakeTokenRepo {
	return &fakeTokenRepo{tokens: make(map[string]*RefreshToken), nextID: 1}
}

func key(hash []byte) string { return string(hash) }

func (f *fakeTokenRepo) Create(_ context.Context, t *RefreshToken) error {
	t.ID = f.nextID
	f.nextID++
	f.tokens[key(t.Hash)] = t
	return nil
}

func (f *fakeTokenRepo) ByHash(_ context.Context, hash []byte) (*RefreshToken, error) {
	t, ok := f.tokens[key(hash)]
	if !ok {
		return nil, nil
	}
	// Simulates the client hanging up in the window between the lookup
	// completing and the next statement being issued. The query has already
	// returned its row, so the cancellation arrives too late to affect it -
	// which is why `ByHash` ignores the context and this hook fires after the
	// result is in hand.
	if f.cancelOnByHash != nil {
		f.cancelOnByHash()
	}
	return t, nil
}

func (f *fakeTokenRepo) Rotate(
	_ context.Context,
	oldHash []byte,
	newToken *RefreshToken,
) (bool, error) {
	if f.rotateErr != nil {
		return false, f.rotateErr
	}

	oldToken, ok := f.tokens[key(oldHash)]
	if !ok || !oldToken.RevokedAt.IsZero() {
		return false, nil
	}

	oldToken.RevokedAt = time.Now().UTC()
	newToken.ID = f.nextID
	f.nextID++
	f.tokens[key(newToken.Hash)] = newToken
	return true, nil
}

func (f *fakeTokenRepo) RevokeByHash(_ context.Context, hash []byte) error {
	if t, ok := f.tokens[key(hash)]; ok && t.RevokedAt.IsZero() {
		t.RevokedAt = time.Now().UTC()
	}
	return nil
}

func (f *fakeTokenRepo) RevokeAllByUserID(ctx context.Context, userID int) error {
	f.revokeAll = append(f.revokeAll, userID)

	// A real driver refuses to run against a dead context. Without this the
	// fake would happily revoke everything and the regression this exists to
	// catch could not possibly reproduce.
	if err := ctx.Err(); err != nil {
		return err
	}
	if f.revokeAllErr != nil {
		return f.revokeAllErr
	}

	for _, t := range f.tokens {
		if t.UserID == userID && t.RevokedAt.IsZero() {
			t.RevokedAt = time.Now().UTC()
		}
	}
	return nil
}

func (f *fakeTokenRepo) Update(_ context.Context, _ *RefreshToken) error {
	return nil
}

func newTestService(userRepo UserRepository, tokenRepo RefreshTokenRepository) *AuthService {
	return NewAuthService(userRepo, tokenRepo, "test-secret", 15*time.Minute, 7*24*time.Hour)
}

const testPassword = "correct-horse-battery"

func seedUser(t *testing.T, userRepo *fakeUserRepo) *User {
	t.Helper()
	hash, err := hashPassword(testPassword)
	if err != nil {
		t.Fatalf("hashPassword: %v", err)
	}
	u := &User{Email: "user@example.com", PasswordHash: hash}
	if err := userRepo.Create(context.Background(), u); err != nil {
		t.Fatalf("create user: %v", err)
	}
	return u
}

func TestLogin_SuccessIssuesTokens(t *testing.T) {
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)

	svc := newTestService(userRepo, tokenRepo)

	access, refresh, err := svc.Login(context.Background(), "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}
	if access == "" || refresh == "" {
		t.Fatal("expected non-empty token pair")
	}
	if len(tokenRepo.tokens) != 1 {
		t.Fatalf("expected 1 stored refresh token, got %d", len(tokenRepo.tokens))
	}
}

func TestLogin_WrongPasswordAndUnknownUserAreIndistinguishable(t *testing.T) {
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	_, _, errWrong := svc.Login(context.Background(), "user@example.com", "wrong")
	_, _, errUnknown := svc.Login(context.Background(), "nobody@example.com", "whatever")

	if errWrong != ErrInvalidCredentials || errUnknown != ErrInvalidCredentials {
		t.Fatal("both cases must return ErrInvalidCredentials to prevent user enumeration")
	}
}

func TestRegister_DuplicateEmailRejected(t *testing.T) {
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	_, _, err := svc.Register(context.Background(), "user@example.com", "irrelevant")
	if err != ErrUserAlreadyExists {
		t.Fatalf("want ErrUserAlreadyExists, got %v", err)
	}
}

func TestRefresh_RotatesTokens(t *testing.T) {
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	_, refresh1, err := svc.Login(context.Background(), "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}

	access2, refresh2, err := svc.Refresh(context.Background(), refresh1)
	if err != nil {
		t.Fatalf("Refresh: %v", err)
	}

	if access2 == "" || refresh2 == "" || refresh2 == refresh1 {
		t.Fatal("refresh must return a fresh token pair with a new refresh token")
	}

	// Old token must be revoked after rotation.
	_, _, err = svc.Refresh(context.Background(), refresh1)
	if err != ErrRevokedRefreshToken {
		t.Fatalf("rotated-in token must be revoked, got %v", err)
	}
}

func TestRefresh_RotationFailureKeepsCurrentTokenUsable(t *testing.T) {
	ctx := context.Background()
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	_, refresh, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}

	tokenRepo.rotateErr = errors.New("replacement insert failed")
	_, _, err = svc.Refresh(ctx, refresh)
	if !errors.Is(err, tokenRepo.rotateErr) {
		t.Fatalf("want replacement error, got %v", err)
	}

	stored, err := tokenRepo.ByHash(ctx, hashToken(refresh))
	if err != nil {
		t.Fatalf("ByHash: %v", err)
	}
	if stored == nil || !stored.RevokedAt.IsZero() {
		t.Fatal("failed replacement issuance must leave the current token active")
	}

	tokenRepo.rotateErr = nil
	if _, _, err := svc.Refresh(ctx, refresh); err != nil {
		t.Fatalf("current token should remain usable for retry: %v", err)
	}
}

// Regression test for T-05: presenting a revoked (reused) refresh token must
// invalidate every session of that user.
func TestRefresh_ReuseRevokesAllSessions(t *testing.T) {
	ctx := context.Background()
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	// Session A.
	_, refreshA, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login A: %v", err)
	}

	// Rotate session A -> attacker obtains refreshB, victim keeps using refreshA? No:
	// rotation revokes refreshA and issues refreshB. Attacker replays refreshA.
	_, refreshB, err := svc.Refresh(ctx, refreshA)
	if err != nil {
		t.Fatalf("Refresh (rotation): %v", err)
	}

	// Attacker replays the now-revoked refreshA.
	_, _, err = svc.Refresh(ctx, refreshA)
	if err != ErrRevokedRefreshToken {
		t.Fatalf("want ErrRevokedRefreshToken on reuse, got %v", err)
	}

	// The legitimate session B must be dead too.
	if len(tokenRepo.revokeAll) != 1 || tokenRepo.revokeAll[0] != 1 {
		t.Fatalf("reuse must revoke all sessions for user 1, got %v", tokenRepo.revokeAll)
	}

	_, _, err = svc.Refresh(ctx, refreshB)
	if err != ErrRevokedRefreshToken {
		t.Fatalf("session B should be revoked after reuse detection, got %v", err)
	}
}

func TestRefresh_ReuseRevokesAllSessionsAfterClientDisconnect(t *testing.T) {
	// The regression this exists for. Reuse detection runs after the token
	// lookup has already answered, so the client can be gone by then. Passing
	// the request context to the revocation meant a dropped connection aborted
	// the UPDATE and left the stolen token's family alive - silently, because
	// the error was discarded.
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	ctx := context.Background()
	_, refreshA, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}
	_, refreshB, err := svc.Refresh(ctx, refreshA)
	if err != nil {
		t.Fatalf("Refresh (rotation): %v", err)
	}

	// The client vanishes immediately after the replayed token is looked up.
	ctx, cancel := context.WithCancel(ctx)
	tokenRepo.cancelOnByHash = cancel

	_, _, err = svc.Refresh(ctx, refreshA)
	if err != ErrRevokedRefreshToken {
		t.Fatalf("want ErrRevokedRefreshToken on reuse, got %v", err)
	}
	if ctx.Err() == nil {
		t.Fatal("test did not reproduce a disconnected client")
	}

	// The legitimate session must still be dead, even though its owner hung up.
	_, _, err = svc.Refresh(context.Background(), refreshB)
	if err != ErrRevokedRefreshToken {
		t.Fatalf("session B should be revoked after reuse detection, got %v", err)
	}
}

func TestRefresh_ReuseRevokeFailureStillDenies(t *testing.T) {
	// A revocation that fails for a reason other than a dead context must not
	// turn into a successful refresh. The caller presented a revoked token, so
	// the request is denied regardless; reporting an infrastructure error
	// instead would tell a caller holding a stolen credential more about our
	// internals without protecting anything.
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	tokenRepo.revokeAllErr = errors.New("connection reset by peer")
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	ctx := context.Background()
	_, refreshA, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}
	if _, _, err := svc.Refresh(ctx, refreshA); err != nil {
		t.Fatalf("Refresh (rotation): %v", err)
	}

	_, _, err = svc.Refresh(ctx, refreshA)
	if !errors.Is(err, ErrRevokedRefreshToken) {
		t.Fatalf("want ErrRevokedRefreshToken even when revocation fails, got %v", err)
	}
	if len(tokenRepo.revokeAll) != 1 {
		t.Fatalf("revocation should still have been attempted, got %v", tokenRepo.revokeAll)
	}
}

func TestRefresh_ExpiredTokenRejected(t *testing.T) {
	ctx := context.Background()
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)

	// Custom service with a negative TTL so the token is born expired.
	svc := NewAuthService(userRepo, tokenRepo, "test-secret", time.Minute, -time.Hour)

	_, refresh, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}

	if _, _, err := svc.Refresh(ctx, refresh); err != ErrExpiredRefreshToken {
		t.Fatalf("want ErrExpiredRefreshToken, got %v", err)
	}
}

func TestLogout_RevokesToken(t *testing.T) {
	ctx := context.Background()
	userRepo := newFakeUserRepo()
	tokenRepo := newFakeTokenRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, tokenRepo)

	_, refresh, err := svc.Login(ctx, "user@example.com", testPassword)
	if err != nil {
		t.Fatalf("Login: %v", err)
	}

	if err := svc.Logout(ctx, refresh); err != nil {
		t.Fatalf("Logout: %v", err)
	}

	if _, _, err := svc.Refresh(ctx, refresh); err != ErrRevokedRefreshToken {
		t.Fatalf("token must be revoked after logout, got %v", err)
	}
}

func TestGenerateAccessToken_ContainsUserIDClaim(t *testing.T) {
	token, err := generateAccessToken(42, "k", time.Minute)
	if err != nil {
		t.Fatalf("generateAccessToken: %v", err)
	}

	var claims AccessTokenClaims
	parsed, err := jwt.ParseWithClaims(token, &claims, func(*jwt.Token) (any, error) {
		return []byte("k"), nil
	})
	if err != nil || !parsed.Valid {
		t.Fatalf("token should parse: %v", err)
	}
	if claims.UserID != 42 {
		t.Fatalf("want userID 42, got %d", claims.UserID)
	}
}

func TestRegister_RejectsPasswordOutsidePolicy(t *testing.T) {
	ctx := context.Background()
	svc := newTestService(newFakeUserRepo(), newFakeTokenRepo())

	for _, password := range []string{"", "abc12", string(make([]byte, 73))} {
		if _, _, err := svc.Register(ctx, "new@example.com", password); err != ErrInvalidPassword {
			t.Fatalf("Register(%d bytes): want ErrInvalidPassword, got %v", len(password), err)
		}
	}

	// Boundary values must be accepted.
	if _, _, err := svc.Register(ctx, "a@example.com", "abcdef"); err != nil {
		t.Fatalf("Register(6 bytes): %v", err)
	}
	long := make([]byte, 72)
	for i := range long {
		long[i] = 'x'
	}
	if _, _, err := svc.Register(ctx, "b@example.com", string(long)); err != nil {
		t.Fatalf("Register(72 bytes): %v", err)
	}
}

func TestUserExists(t *testing.T) {
	ctx := context.Background()
	userRepo := newFakeUserRepo()
	seedUser(t, userRepo)
	svc := newTestService(userRepo, newFakeTokenRepo())

	exists, err := svc.UserExists(ctx, "user@example.com")
	if err != nil || !exists {
		t.Fatalf("existing user: exists=%v err=%v", exists, err)
	}

	exists, err = svc.UserExists(ctx, "nobody@example.com")
	if err != nil || exists {
		t.Fatalf("unknown user: exists=%v err=%v", exists, err)
	}
}
