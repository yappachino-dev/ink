ifneq (,$(wildcard ./.env))
    include ./.env
    export
endif

.PHONY: up build down restart status logs

up:
	@echo "Spinning up containers..."
	docker compose up -d

build:
	@echo "Building up containers..."
	docker compose up --build -d

down:
	@echo "Tearing down containers..."
	docker compose down

restart:
	@echo "Restarting containers..."
	docker compose down
	docker compose up -d

status:
	docker compose ps

logs:
	docker compose logs -f

.PHONY: migrate-up migrate-down migrate-status reset-db users

# --- Client Drift schema evolution ---

# Run after changing the Drift schema, then bump schemaVersion in database.dart:
#   1. make schema-dump  (snapshots the CURRENT lib schema; do this before bumping)
#   2. bump schemaVersion + write onUpgrade step
#   3. make schema-generate  (regenerates test/migrations helpers)
#   4. extend client/test/migrations/migration_test.dart
schema-dump:
	cd client && dart run drift_dev schema dump lib/app/database/database.dart drift_schemas/

schema-generate:
	cd client && dart run drift_dev schema generate drift_schemas/ test/migrations/

MIGRATE_URL ?= postgres://$(DB_USER):$(DB_PASSWORD)@localhost:5432/$(DB_NAME)?sslmode=disable

migrate-up:
	go run ./services/core/cmd/migrate -url "$(MIGRATE_URL)" up

migrate-down:
	go run ./services/core/cmd/migrate -url "$(MIGRATE_URL)" down

migrate-status:
	go run ./services/core/cmd/migrate -url "$(MIGRATE_URL)" status

reset-db:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO postgres; GRANT ALL ON SCHEMA public TO public;"
	$(MAKE) migrate-up

users:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from users;"

user-keys:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from user_keys;"

notes:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from notes;"

notebooks:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from notebooks;"

tokens:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from refresh_tokens;"

.PHONY: check-architecture check-spacing install-hooks
## Point git at .githooks/, whose pre-push refuses to push the base branch. That
## check lives here rather than on the remote because this repo has no branch
## protection on the current plan. Run once per clone.
install-hooks:
	git config core.hooksPath .githooks
	@echo "core.hooksPath = $$(git config core.hooksPath)"
## Architecture boundaries are a static check over lib/ and test/ with no base
## ref, so it is a CI step. Spacing verification diffs against $(BASE) and
## cannot be: actions/checkout uses fetch-depth 1, so there is no origin/main.
check-architecture:
	cd client && dart run tool/check_architecture.dart
check-spacing:
	cd client && dart run tool/verify_spacing_tokens.dart $(BASE)
