package service

import (
	"errors"

	"github.com/yappachino-dev/ink/services/core/internal/auth/utils"
)

var ErrInvalidLogoutToken = errors.New("invalid token")

func (s *AuthService) Logout(refreshToken string) error {
	if refreshToken == "" {
		return ErrInvalidLogoutToken
	}

	tokenHash := utils.HashToken(refreshToken)

	err := s.refreshTokenRepo.RevokeByTokenHash(tokenHash)
	if err != nil {
		return err
	}

	return nil
}
