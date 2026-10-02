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
	Notebooks []Notebook
	Notes     []Note
}

type Note struct {
	ID         uuid.UUID
	UserID     int
	NotebookID *uuid.UUID

	EncryptedTitle   []byte
	EncryptedContent []byte

	Version      int
	SyncSequence int

	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}

type Notebook struct {
	ID     uuid.UUID
	UserID int

	EncryptedContent []byte

	Version      int
	SyncSequence int

	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}
