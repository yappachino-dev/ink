package service

import (
	"github.com/yappachino-dev/ink/services/core/internal/dto"
	"github.com/yappachino-dev/ink/services/core/internal/user/repository"
)

type KeyService struct {
	keyRepo *repository.KeyRepository
}

func NewKeyService(keyRepo *repository.KeyRepository) *KeyService {
	return &KeyService{keyRepo: keyRepo}
}

func (s *KeyService) GetKeys(userID int) ([]dto.KeyDTO, error) {
	return s.keyRepo.GetByUserID(userID)
}

func (s *KeyService) SaveKeys(userID int, keys []dto.KeyDTO) error {
	return s.keyRepo.UpsertMany(userID, keys)
}
