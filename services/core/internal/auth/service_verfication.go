package auth

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/rand"
	"time"
)

type EmailVerificationRepository interface {
	CreateEmailVerification(ctx context.Context, email string, codeHash string) error
	LatestByEmail(ctx context.Context, email string) (*EmailVerification, error)
	MarkAsUsed(ctx context.Context, id int) error
	MarkAllAsUsed(ctx context.Context, email string) error
}

type EmailVerificationService struct {
	repo EmailVerificationRepository
}

func NewEmailVerificationService(repo EmailVerificationRepository) *EmailVerificationService {
	return &EmailVerificationService{repo: repo}
}

func generateVerificationCode() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

func hashVerificationCode(code string) string {
	hash := sha256.Sum256([]byte(code))
	return hex.EncodeToString(hash[:])
}

func (s *EmailVerificationService) CreateVerification(ctx context.Context, email string) (string, error) {
	err := s.repo.MarkAllAsUsed(ctx, email)
	if err != nil {
		return "", err
	}

	code := generateVerificationCode()
	codeHash := hashVerificationCode(code)

	err = s.repo.CreateEmailVerification(ctx, email, codeHash)
	if err != nil {
		return "", err
	}
	return code, nil
}

func (s *EmailVerificationService) ConfirmCode(ctx context.Context, email string, code string) error {
	verification, err := s.repo.LatestByEmail(ctx, email)
	if err != nil {
		return err
	}
	if verification == nil {
		return fmt.Errorf("no verification record found")
	}

	if !verification.UsedAt.IsZero() {
		return fmt.Errorf("verification code already used")
	}

	if time.Now().UTC().After(verification.ExpiresAt) {
		return fmt.Errorf("verification code expired")
	}

	codeHash := hashVerificationCode(code)
	if verification.CodeHash != codeHash {
		return fmt.Errorf("invalid verification code")
	}

	return s.repo.MarkAsUsed(ctx, verification.ID)
}
