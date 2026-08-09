from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.security import hash_password, verify_password
from app.models.account import Account, AccountStatus, SignupSource
from app.models.user import User, UserRole


async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    result = await db.execute(
        select(User)
        .join(User.account)
        .where(Account.email == email)
        .options(selectinload(User.account))
    )
    return result.scalar_one_or_none()


async def create_user(
    db: AsyncSession,
    email: str,
    password: str,
    name: str,
    signup_source: SignupSource = SignupSource.EMAIL,
    role: UserRole = UserRole.USER,
) -> User:
    account = Account(
        email=email,
        hashed_password=hash_password(password) if password else None,
        signup_source=signup_source,
        status=AccountStatus.VERIFIED,
        is_active=True,
    )
    db.add(account)
    await db.flush()

    user = User(
        account_id=account.id,
        name=name,
        role=role,
        is_active=True,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    await db.refresh(account)
    user.account = account
    return user


async def authenticate_user(db: AsyncSession, email: str, password: str) -> User | None:
    user = await get_user_by_email(db, email)
    if not user or not user.account or not user.is_active or not user.account.is_active:
        return None
    if user.account.status in (AccountStatus.SUSPENDED, AccountStatus.DELETED):
        return None
    if not user.account.hashed_password or not verify_password(
        password, user.account.hashed_password
    ):
        return None
    return user
