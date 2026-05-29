package vault

import "time"

type KeySlot struct {
	UserID           int       `json:"userId"`
	Type             int       `json:"keyType"`
	Salt             []byte    `json:"salt"`
	WrappedMasterKey []byte    `json:"wrappedMasterKey"`
	UpdatedAt        time.Time `json:"updatedAt"`
}
