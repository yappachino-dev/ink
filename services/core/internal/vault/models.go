package vault

import "time"

type KeySlot struct {
	UserID           int
	Type             int
	Salt             []byte
	WrappedMasterKey []byte
	UpdatedAt        time.Time
}
