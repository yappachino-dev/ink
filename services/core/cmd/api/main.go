package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/yappachino-dev/ink/services/core/internal/app"
	"github.com/yappachino-dev/ink/services/core/internal/config"
)

func main() {
	slog.Info("system bootstrapping initiated")

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load configuration", "error", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	application, err := app.New(ctx, cfg)
	if err != nil {
		slog.Error("failed to initialize application", "error", err)
		os.Exit(1)
	}

	if err := application.Run(ctx); err != nil {
		slog.Error("application runtime crash", "error", err)
		os.Exit(1)
	}

	slog.Info("application gracefully terminated")
}
