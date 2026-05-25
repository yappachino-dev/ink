package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/mad-yappachino/ink/services/core/internal/dto"
	"github.com/mad-yappachino/ink/services/core/internal/response"
	"github.com/mad-yappachino/ink/services/core/internal/user/service"
)

type KeyHandler struct {
	keyService *service.KeyService
}

func NewKeyHandler(keyService *service.KeyService) *KeyHandler {
	return &KeyHandler{keyService: keyService}
}

func (h *KeyHandler) GetKeys(c *gin.Context) {
	userID := c.GetInt("user_id")
	keys, err := h.keyService.GetKeys(userID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "failed to fetch keys")
		return
	}
	response.Success(c, http.StatusOK, keys)
}

func (h *KeyHandler) SaveKeys(c *gin.Context) {
	userID := c.GetInt("user_id")
	var req dto.KeysDTO

	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.keyService.SaveKeys(userID, req.Keys); err != nil {
		response.Error(c, http.StatusInternalServerError, "failed to save key")
		return
	}

	response.Success(c, http.StatusOK, gin.H{"message": "key saved successfully"})
}
