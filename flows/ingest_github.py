from datetime import datetime, timezone

from prefect import flow, task

from flows.github_api import fetch_trending_repos
from flows.transform import normalize_repo
from flows.load import load_repos_to_postgres


@task(retries=3, retry_delay_seconds=[10, 30, 60], log_prints=True)
def fetch_language(language: str) -> list[dict]:
    repos = fetch_trending_repos(language)
    print(f"Fetched {len(repos)} repos for {language}")
    return repos


@task(log_prints=True)
def normalize_batch(
    repos: list[dict], language: str, fetched_at: datetime
) -> list[dict]:
    rows = [normalize_repo(r, language, fetched_at) for r in repos]
    print(f"Normalized {len(rows)} repos for {language}")
    return rows


@task(log_prints=True)
def load_batch(rows: list[dict]) -> int:
    count = load_repos_to_postgres(rows)
    print(f"Loaded {count} rows into raw.github_trending")
    return count


@flow(log_prints=True)
def ingest_github_trending(languages: list[str] | None = None):
    if languages is None:
        languages = ["python", "typescript", "rust", "go", "javascript"]

    fetched_at = datetime.now(timezone.utc)

    # Fetch all languages concurrently
    futures = {lang: fetch_language.submit(lang) for lang in languages}

    total_rows = 0
    for lang, future in futures.items():
        repos = future.result()
        rows = normalize_batch(repos, lang, fetched_at)
        count = load_batch(rows)
        total_rows += count

    print(f"Loaded {total_rows} repos across {len(languages)} languages")


if __name__ == "__main__":
    ingest_github_trending()
