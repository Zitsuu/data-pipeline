from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

from flows.config import settings


def get_engine() -> Engine:
    return create_engine(settings.database_url)


def test_connection() -> bool:
    try:
        engine = get_engine()
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
