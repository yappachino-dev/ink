package service

import (
	"github.com/yappachino-dev/ink/services/core/internal/models"
	"github.com/yappachino-dev/ink/services/core/internal/vault/repository"
)

type KeyService struct {
	keyRepo *repository.KeyRepository
}

func NewKeyService(keyRepo *repository.KeyRepository) *KeyService {
	return &KeyService{keyRepo: keyRepo}
}

func (s *KeyService) GetKeys(userID int) ([]models.KeySlot, error) {
	return s.keyRepo.GetByUserID(userID)
}

func (s *KeyService) SaveKeySlots(userID int, keySlots []models.KeySlot) error {
	return s.keyRepo.UpsertMany(userID, keySlots)
}
