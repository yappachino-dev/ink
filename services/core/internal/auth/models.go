package auth

import (
	"time"
)

type User struct {
	ID           int
	Email        string
	PasswordHash string
	SyncCursor   int
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type RefreshToken struct {
	ID        int
	UserID    int
	TokenHash string
	ExpiresAt time.Time
	CreatedAt time.Time
	RevokedAt time.Time
}

type EmailVerification struct {
	ID        int
	Email     string
	CodeHash  string
	CreatedAt time.Time
	ExpiresAt time.Time
	UsedAt    time.Time
}
