package auth

import (
	"context"
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
	return t, nil
}

func (f *fakeTokenRepo) RevokeByHash(_ context.Context, hash []byte) error {
	if t, ok := f.tokens[key(hash)]; ok && t.RevokedAt.IsZero() {
		t.RevokedAt = time.Now().UTC()
	}
	return nil
}

func (f *fakeTokenRepo) RevokeAllByUserID(_ context.Context, userID int) error {
	f.revokeAll = append(f.revokeAll, userID)
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
