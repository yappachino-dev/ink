package auth

import (
	"context"
	"errors"
	"log/slog"
	"time"
)

// How long the reuse-detection revocation may run once it is detached from the
// request. It is a single indexed UPDATE that revokes one user's sessions, so
// this is a backstop against a wedged connection pool rather than a budget for
// real work.
const reuseRevokeTimeout = 2 * time.Second

type UserRepository interface {
	Create(ctx context.Context, user *User) error
	ByEmail(ctx context.Context, email string) (*User, error)
	ByID(ctx context.Context, id int) (*User, error)
}

type RefreshTokenRepository interface {
	Create(ctx context.Context, token *RefreshToken) error
	ByHash(ctx context.Context, hash []byte) (*RefreshToken, error)
	Rotate(ctx context.Context, oldHash []byte, newToken *RefreshToken) (bool, error)
	RevokeByHash(ctx context.Context, hash []byte) error
	RevokeAllByUserID(ctx context.Context, userID int) error
	Update(ctx context.Context, token *RefreshToken) error
}

type AuthService struct {
	userRepo         UserRepository
	refreshTokenRepo RefreshTokenRepository
	jwtSecret        string
	accessTokenTTL   time.Duration
	refreshTokenTTL  time.Duration
}

func NewAuthService(
	userRepo UserRepository,
	refreshTokenRepo RefreshTokenRepository,
	jwtSecret string,
	accessTokenTTL time.Duration,
	refreshTokenTTL time.Duration,
) *AuthService {
	return &AuthService{
		userRepo:         userRepo,
		refreshTokenRepo: refreshTokenRepo,
		jwtSecret:        jwtSecret,
		accessTokenTTL:   accessTokenTTL,
		refreshTokenTTL:  refreshTokenTTL,
	}
}

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserAlreadyExists  = errors.New("user already exists")
	ErrInvalidPassword    = errors.New("password must be between 6 and 72 bytes")

	ErrInvalidRefreshToken = errors.New("invalid refresh token")
	ErrExpiredRefreshToken = errors.New("expired refresh token")
	ErrRevokedRefreshToken = errors.New("revoked refresh token")

	ErrInvalidLogoutToken = errors.New("invalid token")
)

func (s *AuthService) Login(ctx context.Context, email, password string) (string, string, error) {
	user, err := s.userRepo.ByEmail(ctx, email)
	if err != nil {
		return "", "", err
	}
	if user == nil {
		return "", "", ErrInvalidCredentials
	}

	err = checkPasswordHash(password, user.PasswordHash)
	if err != nil {
		return "", "", ErrInvalidCredentials
	}

	return s.issueTokens(ctx, user.ID)
}

func (s *AuthService) Register(ctx context.Context, email, password string) (string, string, error) {
	// bcrypt silently truncates input beyond 72 bytes; reject instead.
	if len(password) < 6 || len(password) > 72 {
		return "", "", ErrInvalidPassword
	}

	existingUser, err := s.userRepo.ByEmail(ctx, email)
	if err != nil {
		return "", "", err
	}
	if existingUser != nil {
		return "", "", ErrUserAlreadyExists
	}

	passwordHash, err := hashPassword(password)
	if err != nil {
		return "", "", err
	}

	user := &User{
		Email:        email,
		PasswordHash: passwordHash,
	}

	err = s.userRepo.Create(ctx, user)
	if err != nil {
		return "", "", err
	}

	return s.issueTokens(ctx, user.ID)
}

// UserExists reports whether an account is registered for the given email.
// Used to fail registration before consuming a single-use verification code.
func (s *AuthService) UserExists(ctx context.Context, email string) (bool, error) {
	user, err := s.userRepo.ByEmail(ctx, email)
	if err != nil {
		return false, err
	}
	return user != nil, nil
}

func (s *AuthService) issueTokens(ctx context.Context, userID int) (string, string, error) {
	accessToken, err := generateAccessToken(userID, s.jwtSecret, s.accessTokenTTL)
	if err != nil {
		return "", "", err
	}

	refreshToken, err := generateRefreshToken()
	if err != nil {
		return "", "", err
	}

	session := &RefreshToken{
		UserID:    userID,
		Hash:      hashToken(refreshToken),
		ExpiresAt: time.Now().UTC().Add(s.refreshTokenTTL),
	}

	err = s.refreshTokenRepo.Create(ctx, session)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

func (s *AuthService) Refresh(ctx context.Context, refreshToken string) (string, string, error) {
	if refreshToken == "" {
		return "", "", ErrInvalidRefreshToken
	}

	tokenHash := hashToken(refreshToken)
	storedToken, err := s.refreshTokenRepo.ByHash(ctx, tokenHash)
	if err != nil {
		return "", "", err
	}
	if storedToken == nil || !storedToken.RevokedAt.IsZero() {
		// Reuse of a revoked token means it likely leaked: revoke every
		// session of the owner as standard refresh-token reuse detection.
		if storedToken != nil {
			s.revokeAllOnReuse(ctx, storedToken.UserID)
		}
		return "", "", ErrRevokedRefreshToken
	}

	if time.Now().UTC().After(storedToken.ExpiresAt) {
		return "", "", ErrExpiredRefreshToken
	}

	accessToken, err := generateAccessToken(storedToken.UserID, s.jwtSecret, s.accessTokenTTL)
	if err != nil {
		return "", "", err
	}

	refreshToken, err = generateRefreshToken()
	if err != nil {
		return "", "", err
	}

	newToken := &RefreshToken{
		UserID:    storedToken.UserID,
		Hash:      hashToken(refreshToken),
		ExpiresAt: time.Now().UTC().Add(s.refreshTokenTTL),
	}

	rotated, err := s.refreshTokenRepo.Rotate(ctx, tokenHash, newToken)
	if err != nil {
		return "", "", err
	}
	if !rotated {
		// Another request may have rotated this token between validation and
		// the atomic update. Treat it as reuse and invalidate every session.
		s.revokeAllOnReuse(ctx, storedToken.UserID)
		return "", "", ErrRevokedRefreshToken
	}

	return accessToken, refreshToken, nil
}

// revokeAllOnReuse kills every session of a user whose refresh token was
// replayed, which is the whole point of reuse detection.
//
// It deliberately does not use the request context. By the time this runs the
// request has already been answered - `ByHash` returned, or `Rotate` reported a
// lost race - so the client may already be gone, and a cancelled context would
// abort the UPDATE and leave the stolen token's family alive. That is the
// likeliest way this silently failed: a mobile client on a flaky network drops
// mid-refresh, which is exactly when a replay is most plausible. Detaching
// costs nothing when the request is healthy and is the difference between
// containing a leak and not when it is not.
//
// A failure here is logged and not returned. The caller is denied either way -
// the token they presented is already revoked - so surfacing an infrastructure
// error instead would tell a caller holding a stolen credential more about our
// internals without protecting anything.
func (s *AuthService) revokeAllOnReuse(ctx context.Context, userID int) {
	detached, cancel := context.WithTimeout(context.WithoutCancel(ctx), reuseRevokeTimeout)
	defer cancel()

	if err := s.refreshTokenRepo.RevokeAllByUserID(detached, userID); err != nil {
		slog.Error(
			"refresh token reuse detected but session revocation failed",
			"userID", userID,
			"error", err,
		)
	}
}

func (s *AuthService) Logout(ctx context.Context, refreshToken string) error {
	if refreshToken == "" {
		return ErrInvalidLogoutToken
	}

	return s.refreshTokenRepo.RevokeByHash(ctx, hashToken(refreshToken))
}
