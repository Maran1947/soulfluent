#!/bin/bash
set -e

echo "Running Alembic database migrations..."
alembic upgrade head || echo "Alembic migration warning/notice encountered"

echo "Starting FastAPI Uvicorn server..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
