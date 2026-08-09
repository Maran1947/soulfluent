"""Add auth.accounts table and update auth.users with 1:1 mapping

Revision ID: 0002
Revises: 0001
Create Date: 2026-08-09

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create Enums in auth schema
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE auth.signup_source_enum AS ENUM ('EMAIL', 'GOOGLE');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    op.execute("""
        DO $$ BEGIN
            CREATE TYPE auth.account_status_enum AS ENUM ('NOT_VERIFIED', 'VERIFIED', 'SUSPENDED', 'DELETED');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    op.execute("""
        DO $$ BEGIN
            CREATE TYPE auth.user_role_enum AS ENUM ('ADMIN', 'USER');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    # 2. Create auth.accounts table
    op.execute("""
        CREATE TABLE IF NOT EXISTS auth.accounts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            email VARCHAR(255) NOT NULL UNIQUE,
            hashed_password VARCHAR(255),
            signup_source auth.signup_source_enum NOT NULL DEFAULT 'EMAIL',
            status auth.account_status_enum NOT NULL DEFAULT 'VERIFIED',
            is_active BOOLEAN NOT NULL DEFAULT TRUE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
    """)

    # 3. Add columns to auth.users individually
    op.execute("ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS account_id UUID;")
    op.execute("ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS role auth.user_role_enum NOT NULL DEFAULT 'USER';")
    op.execute("ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;")
    op.execute("ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();")

    # 4. Data migration for existing users: create corresponding accounts for existing users
    op.execute("""
        DO $$
        DECLARE
            u RECORD;
            acc_id UUID;
        BEGIN
            IF EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_schema = 'auth' AND table_name = 'users' AND column_name = 'email'
            ) THEN
                FOR u IN SELECT id, email, hashed_password, created_at FROM auth.users WHERE account_id IS NULL LOOP
                    INSERT INTO auth.accounts (email, hashed_password, signup_source, status, is_active, created_at, updated_at)
                    VALUES (u.email, u.hashed_password, 'EMAIL', 'VERIFIED', TRUE, COALESCE(u.created_at, NOW()), NOW())
                    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email
                    RETURNING id INTO acc_id;

                    UPDATE auth.users SET account_id = acc_id WHERE id = u.id;
                END LOOP;
            END IF;
        END $$;
    """)

    # 5. Clean up old columns from auth.users
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS email;")
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS hashed_password;")

    # 6. Add constraints & indexes to account_id on auth.users
    op.execute("""
        DO $$ BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.table_constraints 
                WHERE constraint_name = 'fk_users_account_id'
            ) THEN
                ALTER TABLE auth.users ADD CONSTRAINT fk_users_account_id 
                FOREIGN KEY (account_id) REFERENCES auth.accounts(id) ON DELETE CASCADE;
            END IF;
        END $$;
    """)

    op.execute("CREATE UNIQUE INDEX IF NOT EXISTS ix_auth_users_account_id ON auth.users (account_id);")


def downgrade() -> None:
    op.execute("ALTER TABLE auth.users DROP CONSTRAINT IF EXISTS fk_users_account_id;")
    op.execute("DROP INDEX IF EXISTS auth.ix_auth_users_account_id;")
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS account_id;")
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS role;")
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS is_active;")
    op.execute("ALTER TABLE auth.users DROP COLUMN IF EXISTS updated_at;")
    op.execute("DROP TABLE IF EXISTS auth.accounts;")
    op.execute("DROP TYPE IF EXISTS auth.signup_source_enum;")
    op.execute("DROP TYPE IF EXISTS auth.account_status_enum;")
    op.execute("DROP TYPE IF EXISTS auth.user_role_enum;")
