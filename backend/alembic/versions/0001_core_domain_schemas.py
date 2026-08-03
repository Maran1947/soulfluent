"""Initial migration: core domain schemas (auth, conversation, analytics)

Revision ID: 0001
Revises: None
Create Date: 2026-08-04

"""
from pathlib import Path
from typing import Sequence, Union

from alembic import op

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

MIGRATIONS_BASE = Path(__file__).resolve().parents[2] / "migrations"


def _get_sql_file(filename: str) -> Path | None:
    direct = MIGRATIONS_BASE / filename
    if direct.exists():
        return direct
    matches = list(MIGRATIONS_BASE.glob(f"**/{filename}"))
    return matches[0] if matches else None


def _execute_sql_script(sql_path: Path | None) -> None:
    if not sql_path or not sql_path.exists():
        return

    content = sql_path.read_text()
    lines = [line for line in content.splitlines() if not line.strip().startswith("--")]
    clean_sql = "\n".join(lines)

    statements = []
    current = []
    in_dollar_block = False

    for line in clean_sql.splitlines():
        if "$$" in line:
            # Count occurrences of $$ on the line to toggle block state
            dollars = line.count("$$")
            if dollars % 2 != 0:
                in_dollar_block = not in_dollar_block

        current.append(line)

        if not in_dollar_block and line.rstrip().endswith(";"):
            stmt = "\n".join(current).strip()
            if stmt:
                statements.append(stmt)
            current = []

    if current:
        stmt = "\n".join(current).strip()
        if stmt:
            statements.append(stmt)

    for stmt in statements:
        if stmt:
            op.execute(stmt)


def upgrade() -> None:
    _execute_sql_script(_get_sql_file("1_create_schemas.sql"))
    _execute_sql_script(_get_sql_file("2_backfill_data.sql"))


def downgrade() -> None:
    _execute_sql_script(_get_sql_file("down.sql"))
