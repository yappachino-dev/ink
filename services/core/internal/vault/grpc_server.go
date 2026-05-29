package vault

import (
	"context"

	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	vaultv1 "github.com/yappachino-dev/ink/services/gen/pb/vault/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Server struct {
	vaultv1.UnimplementedVaultServiceServer
	keyService *KeyService
}

func NewServer(keyService *KeyService) *Server {
	return &Server{keyService: keyService}
}

func (s *Server) GetKeySlots(ctx context.Context, req *vaultv1.GetKeySlotsRequest) (*vaultv1.GetKeySlotsResponse, error) {
	userID, ok := appctx.UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "missing or invalid authentication credentials")
	}

	keySlots, err := s.keyService.GetKeys(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "failed to fetch key slots")
	}

	return &vaultv1.GetKeySlotsResponse{KeySlots: toProtoSlice(keySlots)}, nil
}

func (s *Server) SaveKeySlots(ctx context.Context, req *vaultv1.SaveKeySlotsRequest) (*vaultv1.SaveKeySlotsResponse, error) {
	userID, ok := appctx.UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "missing or invalid authentication credentials")
	}

	if len(req.KeySlots) == 0 {
		return nil, status.Error(codes.InvalidArgument, "request body must contain key slots")
	}

	modelKeys := toModelSlice(userID, req.KeySlots)

	if err := s.keyService.SaveKeySlots(ctx, userID, modelKeys); err != nil {
		return nil, status.Error(codes.Internal, "failed to save key slots")
	}

	return &vaultv1.SaveKeySlotsResponse{}, nil
}
