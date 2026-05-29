package sync

import (
	"context"

	"github.com/yappachino-dev/ink/services/core/internal/appctx"
	syncv1 "github.com/yappachino-dev/ink/services/gen/pb/sync/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Server struct {
	syncv1.UnimplementedSyncServiceServer
	syncService *SyncService
}

func NewServer(syncService *SyncService) *Server {
	return &Server{syncService: syncService}
}

func (s *Server) Sync(ctx context.Context, req *syncv1.SyncRequest) (*syncv1.SyncResponse, error) {
	userID, ok := appctx.UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "missing or invalid authentication credentials")
	}

	payload, err := toDomain(req)
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "request body malformed: %v", err)
	}

	result, err := s.syncService.Sync(ctx, userID, payload)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to execute domain sync operations: %v", err)
	}

	return toProto(result), nil
}
