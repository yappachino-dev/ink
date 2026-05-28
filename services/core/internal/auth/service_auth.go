package auth

import (
	"errors"
	"time"

	"github.com/yappachino-dev/ink/services/core/internal/models"
)

type UserRepository interface {
	Create(user *models.User) error
	GetByEmail(email string) (*models.User, error)
	GetByID(id int) (*models.User, error)
}

type RefreshTokenRepository interface {
	Create(token *models.RefreshToken) error
	GetByTokenHash(hash string) (*models.RefreshToken, error)
	RevokeByTokenHash(hash string) error
	RevokeAllByUserID(userID int) error
	Update(token *models.RefreshToken) error
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
)

func (s *AuthService) Login(email, password string) (string, string, error) {
	user, err := s.userRepo.GetByEmail(email)
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
	return s.issueTokens(user.ID)
}

func (s *AuthService) Register(email, password string) (string, string, error) {
	existingUser, err := s.userRepo.GetByEmail(email)
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

	user := &models.User{
		Email:        email,
		PasswordHash: passwordHash,
	}

	err = s.userRepo.Create(user)
	if err != nil {
		return "", "", err
	}

	return s.issueTokens(user.ID)
}

func (s *AuthService) issueTokens(userID int) (string, string, error) {
	accessToken, err := GenerateAccessToken(userID, s.jwtSecret, s.accessTokenTTL)
	if err != nil {
		return "", "", err
	}

	refreshToken, err := GenerateRefreshToken()
	if err != nil {
		return "", "", err
	}

	tokenHash := HashToken(refreshToken)

	session := &models.RefreshToken{
		UserID:    userID,
		TokenHash: tokenHash,
		ExpiresAt: time.Now().Add(s.refreshTokenTTL),
	}

	err = s.refreshTokenRepo.RevokeAllByUserID(userID)
	if err != nil {
		return "", "", err
	}

	err = s.refreshTokenRepo.Create(session)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

var (
	ErrInvalidRefreshToken = errors.New("invalid refresh token")
	ErrExpiredRefreshToken = errors.New("expired refresh token")
	ErrRevokedRefreshToken = errors.New("revoked refresh token")
)

func (s *AuthService) Refresh(refreshToken string) (string, string, error) {
	if refreshToken == "" {
		return "", "", ErrInvalidRefreshToken
	}

	tokenHash := HashToken(refreshToken)

	storedToken, err := s.refreshTokenRepo.GetByTokenHash(tokenHash)
	if err != nil {
		return "", "", err
	}

	if storedToken == nil {
		return "", "", ErrRevokedRefreshToken
	}

	if storedToken.RevokedAt != nil {
		return "", "", ErrRevokedRefreshToken
	}

	if time.Now().After(storedToken.ExpiresAt) {
		return "", "", ErrExpiredRefreshToken
	}

	err = s.refreshTokenRepo.RevokeByTokenHash(tokenHash)
	if err != nil {
		return "", "", err
	}

	return s.issueTokens(storedToken.UserID)
}

var ErrInvalidLogoutToken = errors.New("invalid token")

func (s *AuthService) Logout(refreshToken string) error {
	if refreshToken == "" {
		return ErrInvalidLogoutToken
	}

	tokenHash := HashToken(refreshToken)

	err := s.refreshTokenRepo.RevokeByTokenHash(tokenHash)
	if err != nil {
		return err
	}

	return nil
}
