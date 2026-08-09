import uuid

from pydantic import BaseModel, EmailStr, Field

from app.models.account import AccountStatus, SignupSource
from app.models.user import UserRole


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    name: str = Field(min_length=1, max_length=255)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: uuid.UUID
    account_id: uuid.UUID
    email: str
    name: str
    role: UserRole
    signup_source: SignupSource
    status: AccountStatus
    is_active: bool

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
