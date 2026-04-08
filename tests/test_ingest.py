from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest

from flows.github_api import fetch_trending_repos
from flows.transform import normalize_repo
from flows.load import load_repos_to_postgres


FAKE_REPO = {
    "id": 123456,
    "full_name": "test-owner/test-repo",
    "owner": {"login": "test-owner"},
    "html_url": "https://github.com/test-owner/test-repo",
    "description": "A test repository",
    "stargazers_count": 100,
    "forks_count": 20,
    "open_issues_count": 5,
    "watchers_count": 100,
    "created_at": "2026-04-01T00:00:00Z",
    "updated_at": "2026-04-07T12:00:00Z",
    "pushed_at": "2026-04-07T11:00:00Z",
    "topics": ["python", "testing"],
}

FAKE_REPO_2 = {**FAKE_REPO, "id": 789012, "full_name": "test-owner/test-repo-2"}


def test_fetch_trending_repos_returns_items():
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"items": [FAKE_REPO, FAKE_REPO_2]}

    with patch("flows.github_api.requests.get", return_value=mock_response):
        result = fetch_trending_repos("python")

    assert len(result) == 2
    assert result[0]["id"] == 123456
    assert result[1]["id"] == 789012


def test_normalize_repo_keys_and_types():
    fetched_at = datetime(2026, 4, 8, 12, 0, 0, tzinfo=timezone.utc)
    row = normalize_repo(FAKE_REPO, "python", fetched_at)

    expected_keys = {
        "repo_id", "full_name", "owner_login", "html_url", "description",
        "language", "stars", "forks", "open_issues", "watchers",
        "created_at", "updated_at", "pushed_at", "topics", "fetched_at",
    }
    assert set(row.keys()) == expected_keys

    assert isinstance(row["repo_id"], int)
    assert isinstance(row["full_name"], str)
    assert isinstance(row["owner_login"], str)
    assert isinstance(row["stars"], int)
    assert isinstance(row["forks"], int)
    assert isinstance(row["open_issues"], int)
    assert isinstance(row["watchers"], int)
    assert isinstance(row["created_at"], datetime)
    assert isinstance(row["updated_at"], datetime)
    assert isinstance(row["pushed_at"], datetime)
    assert isinstance(row["topics"], list)
    assert isinstance(row["fetched_at"], datetime)

    assert row["repo_id"] == 123456
    assert row["owner_login"] == "test-owner"
    assert row["language"] == "python"
    assert row["topics"] == ["python", "testing"]


@pytest.mark.integration
def test_load_idempotent():
    fetched_at = datetime(2099, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
    rows = [normalize_repo(FAKE_REPO, "python", fetched_at)]

    first_count = load_repos_to_postgres(rows)
    assert first_count == 1

    second_count = load_repos_to_postgres(rows)
    assert second_count == 0

    # Clean up test data
    from flows.db import get_engine
    from sqlalchemy import text

    engine = get_engine()
    with engine.begin() as conn:
        conn.execute(
            text("DELETE FROM raw.github_trending WHERE fetched_at = :ts"),
            {"ts": fetched_at},
        )
