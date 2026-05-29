package vault

import (
	"context"
)

type VaultRepository interface {
	GetKeySlotsByUserID(ctx context.Context, userID int) ([]KeySlot, error)
	UpsertKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error
}

type VaultService struct {
	repo VaultRepository
}

func NewVaultService(keyRepo VaultRepository) *VaultService {
	return &VaultService{repo: keyRepo}
}

func (s *VaultService) GetKeys(ctx context.Context, userID int) ([]KeySlot, error) {
	return s.repo.GetKeySlotsByUserID(ctx, userID)
}

func (s *VaultService) SaveKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error {
	return s.repo.UpsertKeySlots(ctx, userID, keySlots)
}
