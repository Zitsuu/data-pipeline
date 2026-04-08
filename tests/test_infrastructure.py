from sqlalchemy import create_engine, inspect, text

from flows.config import settings
from flows.db import test_connection


def test_db_connection():
    assert test_connection() is True


def test_schemas_exist():
    engine = create_engine(settings.database_url)
    inspector = inspect(engine)
    schemas = inspector.get_schema_names()
    assert "raw" in schemas, f"'raw' schema not found. Schemas: {schemas}"
    assert "analytics" in schemas, f"'analytics' schema not found. Schemas: {schemas}"
