package sync

import (
	"time"

	"github.com/google/uuid"
)

type SyncPayload struct {
	ClientCursor int
	Changes      SyncChanges
}

type SyncResult struct {
	NextCursor int
	Changes    SyncChanges
}

type SyncChanges struct {
	Projects []Project
	Notes    []Note
}

type Note struct {
	ID        uuid.UUID
	UserID    int
	ProjectID *uuid.UUID

	EncryptedTitle   []byte
	EncryptedContent []byte

	Version      int
	SyncSequence int

	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}

type Project struct {
	ID     uuid.UUID
	UserID int

	EncryptedContent []byte

	Version      int
	SyncSequence int

	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}
