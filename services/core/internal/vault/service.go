package vault

import (
	"bytes"
	"context"
	"fmt"
	"strconv"

	"github.com/yappachino-dev/ink/services/core/internal/database"
)

// KeySlotConflictError reports a push that would replace an existing unlock
// slot with different key material.
//
// The `user_keys` primary key is (user_id, key_type), so an upsert always
// targets this account's own row. There is no cross-account collision to
// guard: the real hazard is a second device. Setup generates a fresh master key
// on every run, so a device that runs setup produces a different wrapped key
// for a key_type the account already has. `ON CONFLICT DO UPDATE` would take
// that row silently, and the device holding the previous master key could
// never unlock again.
//
// A push that repeats the stored slot byte for byte is a retry, not a
// conflict, and stays accepted: the client re-pushes pending slots after a
// failed response and must not be punished for it.
type KeySlotConflictError struct {
	KeyType int
}

func (e *KeySlotConflictError) Error() string {
	return fmt.Sprintf(
		"key slot type %s already exists with different key material; "+
			"re-running setup on another device would lock this account out",
		keyTypeName(e.KeyType),
	)
}

// keyTypeName renders a key_type for an error message. Unknown values are
// reported numerically rather than dropped, so a client running a newer build
// still produces a message an operator can act on.
func keyTypeName(keyType int) string {
	switch keyType {
	case KeyTypePIN:
		return "PIN"
	case KeyTypePattern:
		return "PATTERN"
	case KeyTypeRecovery:
		return "RECOVERY"
	default:
		return strconv.Itoa(keyType)
	}
}

// KeyType values mirror vault.v1.KeyType in proto/vault/v1/vault.proto.
const (
	KeyTypeUnspecified = 0
	KeyTypePIN         = 1
	KeyTypePattern     = 2
	KeyTypeRecovery    = 3
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
		// Read inside the transaction so the comparison and the write see the
		// same snapshot. Two concurrent pushes would otherwise both pass the
		// check and the second would still overwrite the first.
		existing, err := s.repo.GetKeySlotsByUserID(txCtx, userID)
		if err != nil {
			return err
		}

		if err := rejectDivergentSlots(keySlots, existing); err != nil {
			return err
		}

		return s.repo.UpsertKeySlots(txCtx, userID, keySlots)
	})
}

// rejectDivergentSlots fails the batch when a pushed slot carries different key
// material than the slot already stored for that type.
//
// The whole batch is rejected rather than the offending slot alone. A partial
// write would leave the account with a mix of master keys, which is the same
// lockout this check exists to prevent.
func rejectDivergentSlots(pushed, existing []KeySlot) error {
	stored := make(map[int]KeySlot, len(existing))
	for _, slot := range existing {
		stored[slot.Type] = slot
	}

	// A batch repeating one key_type would resolve by last-write-wins inside
	// the upsert, so the slot that survives is not necessarily the one the
	// client believes it sent.
	seen := make(map[int]struct{}, len(pushed))

	for _, slot := range pushed {
		if _, duplicate := seen[slot.Type]; duplicate {
			return &KeySlotConflictError{KeyType: slot.Type}
		}
		seen[slot.Type] = struct{}{}

		current, exists := stored[slot.Type]
		if !exists {
			continue
		}

		if !bytes.Equal(current.Salt, slot.Salt) ||
			!bytes.Equal(current.WrappedMasterKey, slot.WrappedMasterKey) {
			return &KeySlotConflictError{KeyType: slot.Type}
		}
	}

	return nil
}
