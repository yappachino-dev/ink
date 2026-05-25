package dto

import (
	"time"
)

type SyncRequest struct {
	Cursor  int         `json:"cursor"`
	Changes SyncChanges `json:"changes"`
}

type SyncResponse struct {
	NextCursor int         `json:"nextCursor"`
	Changes    SyncChanges `json:"changes"`
}

type SyncChanges struct {
	Projects []ProjectSyncDTO `json:"projects"`
	Notes    []NoteSyncDTO    `json:"notes"`
}

type ProjectSyncDTO struct {
	ID               string     `json:"id"`
	EncryptedContent []byte     `json:"encryptedContent"`
	Version          int        `json:"version"`
	CreatedAt        time.Time  `json:"createdAt"`
	UpdatedAt        time.Time  `json:"updatedAt"`
	DeletedAt        *time.Time `json:"deletedAt,omitempty"`
}

type NoteSyncDTO struct {
	ID               string     `json:"id"`
	ProjectID        *string    `json:"projectId"`
	EncryptedTitle   []byte     `json:"encryptedTitle"`
	EncryptedContent []byte     `json:"encryptedContent"`
	Version          int        `json:"version"`
	CreatedAt        time.Time  `json:"createdAt"`
	UpdatedAt        time.Time  `json:"updatedAt"`
	DeletedAt        *time.Time `json:"deletedAt,omitempty"`
}
