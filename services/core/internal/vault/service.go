package vault

import (
	"context"
)

type KeyRepository interface {
	GetByUserID(ctx context.Context, userID int) ([]KeySlot, error)
	UpsertMany(ctx context.Context, userID int, keySlots []KeySlot) error
}

type KeyService struct {
	keyRepo KeyRepository
}

func NewKeyService(keyRepo KeyRepository) *KeyService {
	return &KeyService{keyRepo: keyRepo}
}

func (s *KeyService) GetKeys(ctx context.Context, userID int) ([]KeySlot, error) {
	return s.keyRepo.GetByUserID(ctx, userID)
}

func (s *KeyService) SaveKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error {
	return s.keyRepo.UpsertMany(ctx, userID, keySlots)
}
