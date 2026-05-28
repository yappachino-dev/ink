package vault

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/yappachino-dev/ink/services/core/internal/dto"
	"github.com/yappachino-dev/ink/services/core/internal/models"
	"github.com/yappachino-dev/ink/services/core/internal/response"
)

type KeyHandler struct {
	keyService *KeyService
}

func NewKeyHandler(keyService *KeyService) *KeyHandler {
	return &KeyHandler{keyService: keyService}
}

func (h *KeyHandler) GetKeySlots(c *gin.Context) {
	userID := c.GetInt("user_id")
	keys, err := h.keyService.GetKeys(userID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "failed to fetch keys")
		return
	}

	keysDTO := make([]dto.KeyDTO, 0, len(keys))
	for _, k := range keys {
		keysDTO = append(keysDTO, dto.KeyDTO{
			Type:             k.Type,
			Salt:             k.Salt,
			WrappedMasterKey: k.WrappedMasterKey,
			UpdatedAt:        k.UpdatedAt,
		})
	}

	response.Success(c, http.StatusOK, keysDTO)
}

func (h *KeyHandler) SaveKeySlots(c *gin.Context) {
	userID := c.GetInt("user_id")
	var req dto.KeysDTO

	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "invalid request body")
		return
	}

	keySlots := make([]models.KeySlot, 0, len(req.Keys))
	for _, dto := range req.Keys {
		keySlots = append(keySlots, models.KeySlot{
			UserID:           userID,
			Type:             dto.Type,
			Salt:             dto.Salt,
			WrappedMasterKey: dto.WrappedMasterKey,
			UpdatedAt:        dto.UpdatedAt,
		})
	}

	if err := h.keyService.SaveKeySlots(userID, keySlots); err != nil {
		response.Error(c, http.StatusInternalServerError, "failed to save key")
		return
	}

	response.Success(c, http.StatusOK, gin.H{"message": "key saved successfully"})
}
