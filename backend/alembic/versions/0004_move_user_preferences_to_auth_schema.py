"""Migration: Move user_preferences to auth schema and drop legacy curriculum schema

Revision ID: 0004
Revises: 0003
Create Date: 2026-08-15

"""
from pathlib import Path
from typing import Sequence, Union

from alembic import op

revision: str = "0004"
down_revision: Union[str, None] = "0003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

MIGRATIONS_BASE = Path(__file__).resolve().parents[2] / "migrations"


def _get_sql_file(filename: str) -> Path | None:
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
    _execute_sql_script(_get_sql_file("1_move_user_preferences.sql"))


def downgrade() -> None:
    op.execute("ALTER TABLE auth.user_preferences SET SCHEMA public;")
