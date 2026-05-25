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
