package sync

import (
	"context"
	"errors"
	"log/slog"

	syncv1 "github.com/yappachino-dev/ink/gen/go/pb/sync/v1"
	"github.com/yappachino-dev/ink/services/core/internal/appctx"
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
		if code, ok := syncErrorCode(err); ok {
			slog.Warn("sync rejected", "userID", userID, "error", err)
			return nil, status.Error(code, err.Error())
		}

		slog.Error("sync failed", "userID", userID, "error", err)
		return nil, status.Error(codes.Internal, "internal sync failure")
	}

	return toProto(result), nil
}

// syncErrorCode maps rejected-input failures onto specific status codes. These
// are the client's fault and are safe to report verbatim; anything else stays
// an opaque internal error.
func syncErrorCode(err error) (codes.Code, bool) {
	var (
		duplicateErr *DuplicateEntityIDsError
		ownershipErr *OwnershipConflictError
		referenceErr *NotebookReferenceError
	)

	switch {
	case errors.As(err, &duplicateErr):
		return codes.InvalidArgument, true
	case errors.As(err, &ownershipErr):
		return codes.AlreadyExists, true
	case errors.As(err, &referenceErr):
		return codes.FailedPrecondition, true
	default:
		return codes.OK, false
	}
}
