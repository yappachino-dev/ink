package auth

import (
	"context"
	"log/slog"

	authv1 "github.com/yappachino-dev/ink/services/gen/pb/auth/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Server struct {
	authv1.UnimplementedAuthServiceServer
	authService         *AuthService
	verificationService *VerificationService
}

func NewServer(authService *AuthService, emailEmailVerificationService *VerificationService) *Server {
	return &Server{
		authService:         authService,
		verificationService: emailEmailVerificationService,
	}
}

func (s *Server) VerifyEmail(ctx context.Context, req *authv1.VerifyEmailRequest) (*authv1.VerifyEmailResponse, error) {
	if req.GetEmail() == "" {
		return nil, status.Error(codes.InvalidArgument, "email is required")
	}

	code, err := s.verificationService.CreateVerification(ctx, req.GetEmail())
	if err != nil {
		return nil, status.Error(codes.Internal, "failed to generate email verification")
	}
	// TODO(debt): verification codes are not emailed yet (T-02 in docs/tech-debt.md);
	// they are logged so registration can be tested manually. Remove once SMTP is wired.
	slog.Warn("verification code generated (email delivery not wired)", "code", code)

	return &authv1.VerifyEmailResponse{}, nil
}

func (s *Server) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterResponse, error) {
	if err := s.verificationService.ConfirmCode(ctx, req.GetEmail(), req.GetCode()); err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	accessToken, refreshToken, err := s.authService.Register(ctx, req.GetEmail(), req.GetPassword())
	if err != nil {
		if err == ErrUserAlreadyExists {
			return nil, status.Error(codes.AlreadyExists, err.Error())
		}
		return nil, status.Error(codes.Internal, "internal registration failure")
	}

	return &authv1.RegisterResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

func (s *Server) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginResponse, error) {
	accessToken, refreshToken, err := s.authService.Login(ctx, req.GetEmail(), req.GetPassword())
	if err != nil {
		if err == ErrInvalidCredentials {
			return nil, status.Error(codes.Unauthenticated, err.Error())
		}
		return nil, status.Error(codes.Internal, "internal login failure")
	}

	return &authv1.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

func (s *Server) RefreshToken(ctx context.Context, req *authv1.RefreshTokenRequest) (*authv1.RefreshTokenResponse, error) {
	accessToken, refreshToken, err := s.authService.Refresh(ctx, req.GetRefreshToken())
	if err != nil {
		return nil, status.Error(codes.Unauthenticated, "invalid or expired refresh token")
	}

	return &authv1.RefreshTokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

func (s *Server) Logout(ctx context.Context, req *authv1.LogoutRequest) (*authv1.LogoutResponse, error) {
	err := s.authService.Logout(ctx, req.GetRefreshToken())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "failed to process logout payload")
	}

	return &authv1.LogoutResponse{}, nil
}
