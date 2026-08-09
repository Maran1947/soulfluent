.PHONY: help up down build logs shell install dev lint format typecheck check

help:
	@echo "FluentSoul frontend — commands"
	@echo "  make up        Start frontend via docker compose"
	@echo "  make down      Stop the frontend container"
	@echo "  make build     Rebuild the frontend image"
	@echo "  make logs      Tail logs"
	@echo "  make shell     Shell into the frontend container"
	@echo "  make install   npm install locally (no Docker)"
	@echo "  make dev       npm run dev locally (no Docker)"
	@echo "  make lint      Run ESLint"
	@echo "  make format    Run Prettier auto-formatter"
	@echo "  make typecheck Run TypeScript type checking (tsc --noEmit)"
	@echo "  make check     Run format check, lint, and typecheck"

up:
	docker compose up --build

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

shell:
	docker compose exec frontend sh

install:
	npm install

dev:
	npm run dev

lint:
	npm run lint

format:
	npm run format

typecheck:
	npm run typecheck

check:
	npm run check
