package auth

import (
	"context"
	"testing"

	authv1 "github.com/yappachino-dev/ink/gen/go/pb/auth/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// newRegisterTestServer builds a Server whose verification codes are delivered
// through a capturable fake sender, seeded with one existing user
// ("user@example.com").
func newRegisterTestServer(t *testing.T) (*Server, *fakeCodeSender) {
	t.Helper()

	userRepo := newFakeUserRepo()
	seedUser(t, userRepo)
	sender := &fakeCodeSender{}
	server := NewServer(
		newTestService(userRepo, newFakeTokenRepo()),
		NewVerificationService(&fakeVerificationRepo{}),
		sender,
	)
	return server, sender
}

func deliverCode(t *testing.T, server *Server, sender *fakeCodeSender, email string) string {
	t.Helper()

	if _, err := server.VerifyEmail(context.Background(), &authv1.VerifyEmailRequest{
		Email: email,
	}); err != nil {
		t.Fatalf("verify email: %v", err)
	}
	return sender.lastCode
}

func TestRegister_ExistingEmailFailsWithoutBurningCode(t *testing.T) {
	server, sender := newRegisterTestServer(t)

	code := deliverCode(t, server, sender, "user@example.com")

	resp, err := server.Register(context.Background(), &authv1.RegisterRequest{
		Email:    "user@example.com",
		Password: testPassword,
		Code:     code,
	})
	if status.Code(err) != codes.AlreadyExists {
		t.Fatalf("want AlreadyExists, got %v", err)
	}
	if resp != nil {
		t.Fatal("no tokens must be returned")
	}

	// The single-use code must survive the rejected registration attempt.
	if err := server.verificationService.ConfirmCode(
		context.Background(), "user@example.com", code,
	); err != nil {
		t.Fatalf("code must not be burned by a rejected registration: %v", err)
	}
}

func TestRegister_PasswordOutsidePolicyMapsToInvalidArgument(t *testing.T) {
	server, sender := newRegisterTestServer(t)

	long := make([]byte, 73)
	for i := range long {
		long[i] = 'x'
	}
	for name, password := range map[string]string{
		"too short": "abc12",
		"too long":  string(long),
	} {
		code := deliverCode(t, server, sender, "fresh@example.com")

		_, err := server.Register(context.Background(), &authv1.RegisterRequest{
			Email:    "fresh@example.com",
			Password: password,
			Code:     code,
		})
		if status.Code(err) != codes.InvalidArgument {
			t.Fatalf("%s: want InvalidArgument, got %v", name, err)
		}
	}
}
