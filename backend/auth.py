from helper import verify_password
from Model import User
from typing import Annotated
import jwt
from fastapi import Depends, HTTPException, status
from core.core import SECRET_KEY, ALGORITHM, db, oauth2_scheme
from jwt.exceptions import InvalidTokenError



async def authenticate_user(username: str, password: str) -> User | bool:
    """Authenticate user credentials"""
    user = db.query(User).filter_by(username=username).first()
    if not user or not verify_password(password, user.password):
        return False
    return user

async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]) -> User:
    """Get current user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        token_data = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user = db.query(User).filter_by(username=token_data.get("username")).first()
        if not user:
            raise credentials_exception
        return user
    except InvalidTokenError:
        raise credentials_exception
