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

.PHONY: apply-schema reset-db users

apply-schema:
	cat ./migrations/001_init.sql | docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) 

reset-db:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO postgres; GRANT ALL ON SCHEMA public TO public;"
	$(MAKE) apply-schema

users:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from users;"

user-keys:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from user_keys;"

notes:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from notes;"

projects:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from projects;"

tokens:
	docker exec -i ink-db psql -U $(DB_USER) -d $(DB_NAME) -c "select * from refresh_tokens;"
