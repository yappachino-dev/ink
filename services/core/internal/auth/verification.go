package auth

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"math/big"
	"time"
)

type VerificationRepository interface {
	Create(ctx context.Context, email string, codeHash []byte) error
	LatestByEmail(ctx context.Context, email string) (*Verification, error)
	MarkAsUsed(ctx context.Context, id int) error
	MarkAllAsUsed(ctx context.Context, email string) error
}

type VerificationService struct {
	repo VerificationRepository
}

func NewVerificationService(repo VerificationRepository) *VerificationService {
	return &VerificationService{repo: repo}
}

func (s *VerificationService) CreateVerification(ctx context.Context, email string) (string, error) {
	err := s.repo.MarkAllAsUsed(ctx, email)
	if err != nil {
		return "", err
	}

	code, err := generateVerificationCode()
	if err != nil {
		return "", err
	}

	err = s.repo.Create(ctx, email, hashVerificationCode(code))
	if err != nil {
		return "", err
	}
	return code, nil
}

func (s *VerificationService) ConfirmCode(ctx context.Context, email string, code string) error {
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

	if !bytes.Equal(verification.CodeHash, hashVerificationCode(code)) {
		return fmt.Errorf("invalid verification code")
	}

	return s.repo.MarkAsUsed(ctx, verification.ID)
}

func generateVerificationCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", fmt.Errorf("crypto rand failure: %w", err)
	}

	return fmt.Sprintf("%06d", n.Int64()), nil
}

func hashVerificationCode(code string) []byte {
	hash := sha256.Sum256([]byte(code))
	return hash[:]
}
