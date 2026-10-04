package auth

import (
	"bytes"
	"context"
	"errors"
	"log/slog"
	"strings"
	"testing"

	authv1 "github.com/yappachino-dev/ink/gen/go/pb/auth/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type fakeCodeSender struct {
	calls     []string // "email:code"
	failWith  error
	lastCode  string
	lastEmail string
}

func (f *fakeCodeSender) SendCode(_ context.Context, email, code string) error {
	if f.failWith != nil {
		return f.failWith
	}
	f.lastEmail, f.lastCode = email, code
	f.calls = append(f.calls, email+":"+code)
	return nil
}

func TestVerifyEmailDeliversValidatingCode(t *testing.T) {
	repo := &fakeVerificationRepo{}
	svc := NewVerificationService(repo)
	sender := &fakeCodeSender{}
	server := NewServer(nil, svc, sender)

	ctx := context.Background()
	if _, err := server.VerifyEmail(ctx, &authv1.VerifyEmailRequest{Email: "a@b.c"}); err != nil {
		t.Fatalf("verify email: %v", err)
	}

	if sender.lastEmail != "a@b.c" {
		t.Fatalf("sent to wrong address: %q", sender.lastEmail)
	}
	if len(sender.lastCode) != 6 {
		t.Fatalf("expected 6-digit code, got %q", sender.lastCode)
	}

	// The delivered code must be the one that validates.
	if err := svc.ConfirmCode(ctx, "a@b.c", sender.lastCode); err != nil {
		t.Fatalf("delivered code does not validate: %v", err)
	}
}

func TestVerifyEmailMapsSenderFailureToInternal(t *testing.T) {
	repo := &fakeVerificationRepo{}
	svc := NewVerificationService(repo)
	sender := &fakeCodeSender{failWith: errors.New("delivery unavailable")}
	server := NewServer(nil, svc, sender)

	_, err := server.VerifyEmail(context.Background(), &authv1.VerifyEmailRequest{Email: "a@b.c"})
	if status.Code(err) != codes.Internal {
		t.Fatalf("expected Internal, got %v", err)
	}
}

func TestLogCodeSenderWritesCodeToLog(t *testing.T) {
	var buf bytes.Buffer
	logger := slog.New(slog.NewTextHandler(&buf, &slog.HandlerOptions{Level: slog.LevelDebug}))

	sender := NewLogCodeSender(logger)
	if err := sender.SendCode(context.Background(), "a@b.c", "123456"); err != nil {
		t.Fatalf("send: %v", err)
	}

	out := buf.String()
	for _, want := range []string{"a@b.c", "123456", "development mode"} {
		if !strings.Contains(out, want) {
			t.Errorf("log output missing %q: %s", want, out)
		}
	}
}
