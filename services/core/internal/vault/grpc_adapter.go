package vault

import (
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func toProtoSlice(models []KeySlot) []*vaultv1.KeySlot {
	pbKeySlots := make([]*vaultv1.KeySlot, 0, len(models))
	for _, k := range models {
		pbKeySlots = append(pbKeySlots, &vaultv1.KeySlot{
			Type:             vaultv1.KeyType(k.Type),
			Salt:             k.Salt,
			WrappedMasterKey: k.WrappedMasterKey,
			UpdatedAt:        timestamppb.New(k.UpdatedAt),
		})
	}
	return pbKeySlots
}

func toModelSlice(userID int, pbKeySlots []*vaultv1.KeySlot) []KeySlot {
	keySlots := make([]KeySlot, 0, len(pbKeySlots))
	for _, k := range pbKeySlots {
		keySlots = append(keySlots, KeySlot{
			UserID:           userID,
			Type:             int(k.Type),
			Salt:             k.Salt,
			WrappedMasterKey: k.WrappedMasterKey,
			UpdatedAt:        k.UpdatedAt.AsTime(),
		})
	}
	return keySlots
}
