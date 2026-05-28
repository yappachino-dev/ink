package vault

import (
	"github.com/yappachino-dev/ink/services/core/internal/models"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func toProtoSlice(models []models.KeySlot) []*vaultv1.KeySlot {
	pbKeys := make([]*vaultv1.KeySlot, 0, len(models))
	for _, k := range models {
		pbKeys = append(pbKeys, &vaultv1.KeySlot{
			Type:             vaultv1.KeyType(k.Type),
			Salt:             k.Salt,
			WrappedMasterKey: k.WrappedMasterKey,
			UpdatedAt:        timestamppb.New(k.UpdatedAt),
		})
	}
	return pbKeys
}

func toModelSlice(userID int, pbKeys []*vaultv1.KeySlot) []models.KeySlot {
	modelKeys := make([]models.KeySlot, 0, len(pbKeys))
	for _, k := range pbKeys {
		modelKeys = append(modelKeys, models.KeySlot{
			UserID:           userID,
			Type:             int(k.Type),
			Salt:             k.Salt,
			WrappedMasterKey: k.WrappedMasterKey,
			UpdatedAt:        k.UpdatedAt.AsTime(),
		})
	}
	return modelKeys
}
