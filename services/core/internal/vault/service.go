package vault

import (
	"context"

	"github.com/yappachino-dev/ink/services/core/internal/database"
)

type VaultRepository interface {
	GetKeySlotsByUserID(ctx context.Context, userID int) ([]KeySlot, error)
	UpsertKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error
}

type VaultService struct {
	transactor database.Transactor
	repo       VaultRepository
}

func NewVaultService(transactor database.Transactor, keyRepo VaultRepository) *VaultService {
	return &VaultService{transactor: transactor, repo: keyRepo}
}

func (s *VaultService) GetKeys(ctx context.Context, userID int) ([]KeySlot, error) {
	return s.repo.GetKeySlotsByUserID(ctx, userID)
}

// SaveKeySlots persists all slots atomically: a partial failure must never
// leave the user with an inconsistent set of unlock methods.
func (s *VaultService) SaveKeySlots(ctx context.Context, userID int, keySlots []KeySlot) error {
	return s.transactor.WithinTransaction(ctx, func(txCtx context.Context) error {
		return s.repo.UpsertKeySlots(txCtx, userID, keySlots)
	})
}
