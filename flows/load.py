from sqlalchemy import Column, BigInteger, Integer, Text, DateTime, Table, MetaData
from sqlalchemy.dialects.postgresql import ARRAY, insert

from flows.db import get_engine

metadata = MetaData(schema="raw")

github_trending = Table(
    "github_trending",
    metadata,
    Column("repo_id", BigInteger, primary_key=True),
    Column("full_name", Text, nullable=False),
    Column("owner_login", Text, nullable=False),
    Column("html_url", Text, nullable=False),
    Column("description", Text),
    Column("language", Text, nullable=False),
    Column("stars", Integer, nullable=False),
    Column("forks", Integer, nullable=False),
    Column("open_issues", Integer, nullable=False),
    Column("watchers", Integer, nullable=False),
    Column("created_at", DateTime(timezone=True), nullable=False),
    Column("updated_at", DateTime(timezone=True), nullable=False),
    Column("pushed_at", DateTime(timezone=True), nullable=False),
    Column("topics", ARRAY(Text), nullable=False, server_default="{}"),
    Column("fetched_at", DateTime(timezone=True), primary_key=True),
)


def load_repos_to_postgres(rows: list[dict]) -> int:
    if not rows:
        return 0

    engine = get_engine()
    stmt = insert(github_trending).on_conflict_do_nothing(
        index_elements=["repo_id", "fetched_at"]
    )
    with engine.begin() as conn:
        result = conn.execute(stmt, rows)
        return result.rowcount
