package database

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func Connect(databaseURL string) (*sql.DB, error) {
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database connection: %w", err)
	}

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)

	maxRetries := 5
	backoffDelay := 1 * time.Second

	for attempt := 1; attempt <= maxRetries; attempt++ {
		if err = db.Ping(); err == nil {
			return db, nil
		}

		if attempt == maxRetries {
			break
		}

		log.Printf("Database not ready (attempt %d/%d): %v. Retrying in %v...", attempt, maxRetries, err, backoffDelay)
		time.Sleep(backoffDelay)
		backoffDelay *= 2
	}

	_ = db.Close()
	return nil, fmt.Errorf("failed to ping database after %d attempts: %w", maxRetries, err)
}
