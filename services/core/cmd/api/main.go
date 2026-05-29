package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/yappachino-dev/ink/services/core/internal/app"
	"github.com/yappachino-dev/ink/services/core/internal/config"
)

func main() {
	fmt.Println("System bootstrapping initiated...")

	cfg, err := config.Load()
	print(cfg.DatabaseURL)
	if err != nil {
		panic(fmt.Sprintf("failed to load configurations: %v", err))
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	application := app.New(ctx, cfg)
	if err := application.Run(ctx); err != nil {
		fmt.Fprintf(os.Stderr, "Application runtime system crash error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Application gracefully terminated.")
}
