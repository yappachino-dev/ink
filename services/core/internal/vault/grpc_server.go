package vault

import (
	"context"
	"errors"

	vaultv1 "github.com/yappachino-dev/ink/gen/go/pb/vault/v1"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Server struct {
	vaultv1.UnimplementedVaultServiceServer
	keyService *VaultService
}

func NewServer(keyService *VaultService) *Server {
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

	model, err := toModelSlice(userID, req.KeySlots)
	if err != nil {
		return nil, err
	}

	if err := s.keyService.SaveKeySlots(ctx, userID, model); err != nil {
		// A conflict is the client's problem and the message is safe to return
		// verbatim; anything else stays opaque.
		var conflictErr *KeySlotConflictError
		if errors.As(err, &conflictErr) {
			return nil, status.Error(codes.AlreadyExists, err.Error())
		}

		return nil, status.Error(codes.Internal, "failed to save key slots")
	}

	return &vaultv1.SaveKeySlotsResponse{}, nil
}
