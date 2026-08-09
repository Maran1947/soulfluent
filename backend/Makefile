.PHONY: help up down build logs migrate makemigration migrate-down shell db-shell install \
        db db-down run migrate-local makemigration-local migrate-down-local \
        lint format typecheck check

help:
	@echo "FluentSoul backend — commands"
	@echo ""
	@echo "Native mode (recommended for dev — just Postgres in Docker):"
	@echo "  make db                    Start only Postgres via docker compose"
	@echo "  make db-down               Stop Postgres"
	@echo "  make install               pip install -r requirements.txt (venv assumed active)"
	@echo "  make migrate-local         Run alembic migrations directly (no Docker)"
	@echo "  make makemigration-local m='message'   Autogenerate a revision directly"
	@echo "  make migrate-down-local    Roll back the last migration directly"
	@echo "  make run                   uvicorn app.main:app --reload (no Docker)"
	@echo "  make lint                  Run ruff linter check"
	@echo "  make format                Run ruff auto-formatter & import organizer"
	@echo "  make typecheck             Run pyright type checker"
	@echo "  make check                 Run format, lint, and typecheck"
	@echo ""
	@echo "Full Docker mode (Postgres + backend both containerized):"
	@echo "  make up                    Start db + backend via docker compose"
	@echo "  make down                  Stop services"
	@echo "  make build                 Rebuild the backend image"
	@echo "  make logs                  Tail logs"
	@echo "  make migrate               Run alembic migrations inside the container"
	@echo "  make makemigration m='message'   Autogenerate a revision inside the container"
	@echo "  make migrate-down          Roll back the last migration inside the container"
	@echo "  make shell                 Shell into the backend container"
	@echo "  make db-shell              psql shell into postgres"

# --- Native mode ---------------------------------------------------------

db:
	docker compose up -d db

db-down:
	docker compose stop db

install:
	pip install -r requirements.txt

migrate-local:
	alembic upgrade head

makemigration-local:
	alembic revision --autogenerate -m "$(m)"

migrate-down-local:
	alembic downgrade -1

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

lint:
	ruff check app

format:
	ruff format app
	ruff check --fix app

typecheck:
	pyright app

check: format lint typecheck

# --- Full Docker mode -----------------------------------------------------

up:
	docker compose up --build

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

migrate:
	docker compose exec backend alembic upgrade head

makemigration:
	docker compose exec backend alembic revision --autogenerate -m "$(m)"

migrate-down:
	docker compose exec backend alembic downgrade -1

shell:
	docker compose exec backend bash

db-shell:
	docker compose exec db psql -U soulfluent -d soulfluent

minio:
	docker compose up -d minio

minio-down:
	docker compose stop minio