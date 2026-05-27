package grpc

import (
	"context"
	"errors"

	"github.com/yappachino-dev/ink/services/core/internal/vault/service"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type contextKey string

const userIDKey contextKey = "user_id"

type Server struct {
	vaultv1.UnimplementedVaultServiceServer
	keyService *service.KeyService
}

func NewVaultServer(keyService *service.KeyService) *Server {
	return &Server{keyService: keyService}
}

func (s *Server) GetKeySlots(ctx context.Context, req *vaultv1.GetKeySlotsRequest) (*vaultv1.GetKeySlotsResponse, error) {
	// userID, err := getUserIDFromContext(ctx)
	// if err != nil {
	// 	return nil, status.Error(codes.Unauthenticated, err.Error())
	// }
	userID := 1

	keys, err := s.keyService.GetKeys(userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "failed to fetch key slots")
	}

	return &vaultv1.GetKeySlotsResponse{KeySlots: toProtoSlice(keys)}, nil
}

func (s *Server) SaveKeySlots(ctx context.Context, req *vaultv1.SaveKeySlotsRequest) (*vaultv1.SaveKeySlotsResponse, error) {
	// userID, err := getUserIDFromContext(ctx)
	// if err != nil {
	// 	return nil, status.Error(codes.Unauthenticated, err.Error())
	// }
	userID := 1

	if len(req.KeySlots) == 0 {
		return nil, status.Error(codes.InvalidArgument, "request body must contain key slots")
	}

	modelKeys := toModelSlice(userID, req.KeySlots)

	if err := s.keyService.SaveKeySlots(userID, modelKeys); err != nil {
		return nil, status.Error(codes.Internal, "failed to save key slots")
	}

	return &vaultv1.SaveKeySlotsResponse{}, nil
}

func getUserIDFromContext(ctx context.Context) (int, error) {
	userID, ok := ctx.Value(userIDKey).(int)
	if !ok {
		return 0, errors.New("missing or invalid authentication credentials")
	}
	return userID, nil
}
