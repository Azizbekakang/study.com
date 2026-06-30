# app/main.py
from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import jwt

from app.database import engine, Base, get_db
from app.config import settings
from app.models.users import User, UserRole
from app.schemas.users import UserRegister, UserLogin, TokenResponse
from app.security import get_password_hash, verify_password, create_access_token
from app.utils.i18n import get_translation

app = FastAPI(title=settings.PROJECT_NAME, version="1.0.0")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/login")

# Tizim tilini Request obyekti orqali Middleware-da yoki funksiyada aniqlash
def get_current_lang(request: Request) -> str:
    return request.headers.get("Accept-Language", "uz")

# Loyiha ishga tushganda bazani tayyorlash
@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# JWT tokenni tekshirish va joriy foydalanuvchini qaytarish
async def get_current_user(request: Request, token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    lang = get_current_lang(request)
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=get_translation(lang, "invalid_credentials"))
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=get_translation(lang, "invalid_credentials"))
    
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=get_translation(lang, "user_not_found"))
    return user

# 🌟 ROLLARNI TEKSHIRUVChI KLASS (RBAC)
class RoleChecker:
    def __init__(self, allowed_roles: list[UserRole]):
        self.allowed_roles = allowed_roles

    def __call__(self, request: Request, current_user: User = Depends(get_current_user)):
        lang = get_current_lang(request)
        if current_user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=get_translation(lang, "permission_denied")
            )
        return current_user

# --- AUTH ENDPOINTLARI ---

@app.post("/api/v1/auth/register", status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister, db: AsyncSession = Depends(get_db)):
    hashed = get_password_hash(user_data.password)
    new_user = User(
        full_name=user_data.full_name,
        email=user_data.email,
        hashed_password=hashed,
        role=user_data.role
    )
    db.add(new_user)
    await db.commit()
    return {"message": "User registered successfully"}

@app.post("/api/v1/auth/login", response_model=TokenResponse)
async def login(request: Request, login_data: UserLogin, db: AsyncSession = Depends(get_db)):
    lang = get_current_lang(request)
    result = await db.execute(select(User).where(User.email == login_data.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(login_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=get_translation(lang, "invalid_credentials"))
    
    token = create_access_token(data={"sub": user.email})
    return {"access_token": token, "token_type": "bearer"}

# --- FAQAT O'QITUVCHI VA DIREKTOR KIRA OLADIGAN ENDPOINT (TEST) ---
@app.get("/api/v1/teacher/dashboard")
async def get_teacher_dashboard(
    current_user: User = Depends(RoleChecker([UserRole.TEACHER, UserRole.PRINCIPAL]))
):
    return {"message": f"Xush kelibsiz Ustoz, {current_user.full_name}. Bu yerda siz sinf jurnallarini boshqara olasiz."}
