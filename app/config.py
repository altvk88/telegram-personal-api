import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    API_ID: int = int(os.getenv("API_ID", "24010738"))
    API_HASH: str = os.getenv("API_HASH", "4760fca1c08d7aa88e7e974cb77e11a1")
    ADMIN_USERNAME: str = os.getenv("ADMIN_USERNAME", "admin")
    ADMIN_PASSWORD: str = os.getenv("ADMIN_PASSWORD", "password")
    SESSION_NAME: str = os.getenv("SESSION_NAME", "telegram_user_session")
    SESSION_PATH: str = "sessions"

    class Config:
        env_file = ".env"

settings = Settings()
