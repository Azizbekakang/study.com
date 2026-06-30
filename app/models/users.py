import Enum
from enum import Enum
from sqlalchemy import String, Integer, Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base

class UserRole(str, Enum):
    SUPERADMIN = "superadmin"
    PRINCIPAL = "principal"   # Direktor
    TEACHER = "teacher"       # O'qituvchi
    STUDENT = "student"       # O'quvchi
    PARENT = "parent"         # Ota-ona

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(SQLEnum(UserRole), default=UserRole.STUDENT, nullable=False)
