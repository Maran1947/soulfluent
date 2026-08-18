from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.security import decode_access_token
from app.database import get_db
from app.models.user import User

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization token. Please log in.",
        )
    user_id = decode_access_token(credentials.credentials)
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token"
        )
    result = await db.execute(
        select(User).where(User.id == user_id).options(selectinload(User.account))
    )
    user = result.scalar_one_or_none()
    if user is None or not user.is_active or (user.account and not user.account.is_active):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or inactive"
        )
    return user


async def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User | None:
    if credentials is None or not credentials.credentials:
        return None
    try:
        user_id = decode_access_token(credentials.credentials)
        if user_id is None:
            return None
        result = await db.execute(
            select(User).where(User.id == user_id).options(selectinload(User.account))
        )
        user = result.scalar_one_or_none()
        if user is None or not user.is_active or (user.account and not user.account.is_active):
            return None
        return user
    except Exception:
        return None


async def get_admin_user(
    current_user: User = Depends(get_current_user),
) -> User:
    from app.models.user import UserRole
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access Denied: Only users with ADMIN role can access administrative resources.",
        )
    return current_user
