from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "SmartEdu Next-Gen Platform"
    DATABASE_URL: str = "postgresql+asyncpg://postgres:secret@localhost:5432/smartedu_db"
    
    # JWT Xavfsizlik sozlamalari
    JWT_SECRET_KEY: str = "SUPER_SECRET_KEY_META_LEVEL_99" # Haqiqiy loyihada maxfiy tutiladi
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 # 1 kun

    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()
