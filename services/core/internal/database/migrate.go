package database

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"

	"github.com/pressly/goose/v3"

	"github.com/yappachino-dev/ink/services/core/db/migrations"
)

// Migrate applies all pending embedded SQL migrations. It is idempotent and
// safe to call on every boot: goose tracks the applied version in the
// database's goose_db_version table.
func Migrate(ctx context.Context, db *sql.DB) error {
	goose.SetBaseFS(migrations.FS)

	if err := goose.SetDialect("postgres"); err != nil {
		return fmt.Errorf("failed to set migration dialect: %w", err)
	}

	if err := goose.UpContext(ctx, db, "."); err != nil {
		return fmt.Errorf("failed to apply migrations: %w", err)
	}

	version, err := goose.GetDBVersionContext(ctx, db)
	if err != nil {
		return fmt.Errorf("failed to read migration version: %w", err)
	}

	slog.Info("database migrations up to date", "version", version)

	return nil
}
