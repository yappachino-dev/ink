// Command migrate is a small CLI wrapper around the embedded goose migrations.
// It exists for local development and operational work; the API server runs
// the same migrations automatically on boot.
//
// Usage:
//
//	go run ./cmd/migrate [up|down|status|reset] [-url <database_url>]
package main

import (
	"context"
	"database/sql"
	"errors"
	"flag"
	"fmt"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"

	"github.com/yappachino-dev/ink/services/core/db/migrations"
)

func main() {
	url := flag.String("url", os.Getenv("DATABASE_URL"), "postgres connection URL (defaults to DATABASE_URL)")
	flag.Parse()

	command := flag.Arg(0)
	if command == "" {
		fatal(errors.New("missing command: expected one of up|down|status|reset"))
	}

	if err := run(context.Background(), command, *url); err != nil {
		fatal(err)
	}
}

func run(ctx context.Context, command, url string) error {
	if url == "" {
		return errors.New("no database URL: pass -url or set DATABASE_URL")
	}

	goose.SetBaseFS(migrations.FS)
	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("failed to set migration dialect: %w", err)
	}

	db, err := sql.Open("pgx", url)
	if err != nil {
		return fmt.Errorf("failed to open database: %w", err)
	}
	defer db.Close()

	switch command {
	case "up":
		return goose.UpContext(ctx, db, "migrations")
	case "down":
		return goose.DownContext(ctx, db, "migrations")
	case "status":
		return goose.StatusContext(ctx, db, "migrations")
	case "reset":
		if err := goose.ResetContext(ctx, db, "migrations"); err != nil {
			return err
		}
		return goose.UpContext(ctx, db, "migrations")
	default:
		return fmt.Errorf("unknown command %q: expected one of up|down|status|reset", command)
	}
}

func fatal(err error) {
	fmt.Fprintln(os.Stderr, "migrate:", err)
	os.Exit(1)
}
