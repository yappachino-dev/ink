package vault

import (
	"github.com/yappachino-dev/ink/services/core/internal/models"
)

type KeyService struct {
	keyRepo *KeyRepository
}

func NewKeyService(keyRepo *KeyRepository) *KeyService {
	return &KeyService{keyRepo: keyRepo}
}

func (s *KeyService) GetKeys(userID int) ([]models.KeySlot, error) {
	return s.keyRepo.GetByUserID(userID)
}

func (s *KeyService) SaveKeySlots(userID int, keySlots []models.KeySlot) error {
	return s.keyRepo.UpsertMany(userID, keySlots)
}
