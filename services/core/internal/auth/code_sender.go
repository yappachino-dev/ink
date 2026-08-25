package auth

import (
	"context"
	"log/slog"
)

// CodeSender delivers verification codes to the user. Production sends real
// email; development logs the code (see LogCodeSender). Chosen at the
// composition root based on APP_ENV.
type CodeSender interface {
	SendCode(ctx context.Context, email, code string) error
}

// LogCodeSender "delivers" codes by writing them to the log. Never use in
// production: the code is a bearer secret for account creation.
type LogCodeSender struct {
	logger *slog.Logger
}

func NewLogCodeSender(logger *slog.Logger) *LogCodeSender {
	return &LogCodeSender{logger: logger}
}

func (s *LogCodeSender) SendCode(_ context.Context, email, code string) error {
	s.logger.Info(
		"verification code generated (development mode: not emailed)",
		"email", email,
		"code", code,
	)
	return nil
}
