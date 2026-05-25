package models

type UserKeys struct {
	ID               int    `json:"id"`
	UserID           int    `json:"userId"`
	KeyType          string `json:"keyType"`
	Salt             []byte `json:"salt"`
	WrappedMasterKey []byte `json:"wrappedMasterKey"`
}
