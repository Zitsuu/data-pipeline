from datetime import datetime, timedelta, timezone

import requests

from flows.config import settings


class RateLimitError(Exception):
    def __init__(self, reset_time: int):
        self.reset_time = reset_time
        reset_dt = datetime.fromtimestamp(reset_time, tz=timezone.utc)
        super().__init__(
            f"GitHub API rate limit exceeded. Resets at {reset_dt.isoformat()}"
        )


def fetch_trending_repos(
    language: str, since: str = "daily", per_page: int = 50
) -> list[dict]:
    date_cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).strftime("%Y-%m-%d")
    query = f"created:>{date_cutoff} language:{language}"

    headers = {"Accept": "application/vnd.github.v3+json"}
    if settings.github_token:
        headers["Authorization"] = f"Bearer {settings.github_token}"

    response = requests.get(
        "https://api.github.com/search/repositories",
        params={
            "q": query,
            "sort": "stars",
            "order": "desc",
            "per_page": per_page,
        },
        headers=headers,
        timeout=30,
    )

    if response.status_code == 403:
        remaining = response.headers.get("X-RateLimit-Remaining", "")
        if remaining == "0":
            reset_time = int(response.headers.get("X-RateLimit-Reset", 0))
            raise RateLimitError(reset_time)

    if response.status_code != 200:
        raise Exception(
            f"GitHub API returned {response.status_code}: {response.text}"
        )

    return response.json()["items"]
