package auth

import (
	"context"
	"errors"
	"time"
)

type UserRepository interface {
	Create(ctx context.Context, user *User) error
	ByEmail(ctx context.Context, email string) (*User, error)
	ByID(ctx context.Context, id int) (*User, error)
}

type RefreshTokenRepository interface {
	Create(ctx context.Context, token *RefreshToken) error
	ByHash(ctx context.Context, hash string) (*RefreshToken, error)
	RevokeByHash(ctx context.Context, hash string) error
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

	err = CheckPasswordHash(password, user.PasswordHash)
	if err != nil {
		return "", "", ErrInvalidCredentials
	}

	return s.issueTokens(ctx, user.ID)
}

func (s *AuthService) Register(ctx context.Context, email, password string) (string, string, error) {
	existingUser, err := s.userRepo.ByEmail(ctx, email)
	if err != nil {
		return "", "", err
	}
	if existingUser != nil {
		return "", "", ErrUserAlreadyExists
	}

	passwordHash, err := HashPassword(password)
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

func (s *AuthService) issueTokens(ctx context.Context, userID int) (string, string, error) {
	accessToken, err := GenerateAccessToken(userID, s.jwtSecret, s.accessTokenTTL)
	if err != nil {
		return "", "", err
	}

	refreshToken, err := GenerateRefreshToken()
	if err != nil {
		return "", "", err
	}

	tokenHash := HashToken(refreshToken)
	session := &RefreshToken{
		UserID:    userID,
		TokenHash: tokenHash,
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

	tokenHash := HashToken(refreshToken)
	storedToken, err := s.refreshTokenRepo.ByHash(ctx, tokenHash)
	if err != nil {
		return "", "", err
	}
	if storedToken == nil || !storedToken.RevokedAt.IsZero() {
		return "", "", ErrRevokedRefreshToken
	}

	if time.Now().UTC().After(storedToken.ExpiresAt) {
		return "", "", ErrExpiredRefreshToken
	}

	err = s.refreshTokenRepo.RevokeByHash(ctx, tokenHash)
	if err != nil {
		return "", "", err
	}

	return s.issueTokens(ctx, storedToken.UserID)
}

func (s *AuthService) Logout(ctx context.Context, refreshToken string) error {
	if refreshToken == "" {
		return ErrInvalidLogoutToken
	}

	tokenHash := HashToken(refreshToken)
	return s.refreshTokenRepo.RevokeByHash(ctx, tokenHash)
}
