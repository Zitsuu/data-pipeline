from datetime import datetime


def normalize_repo(repo: dict, language: str, fetched_at: datetime) -> dict:
    return {
        "repo_id": repo["id"],
        "full_name": repo["full_name"],
        "owner_login": repo["owner"]["login"],
        "html_url": repo["html_url"],
        "description": repo.get("description"),
        "language": language,
        "stars": repo["stargazers_count"],
        "forks": repo["forks_count"],
        "open_issues": repo["open_issues_count"],
        "watchers": repo["watchers_count"],
        "created_at": datetime.fromisoformat(repo["created_at"].replace("Z", "+00:00")),
        "updated_at": datetime.fromisoformat(repo["updated_at"].replace("Z", "+00:00")),
        "pushed_at": datetime.fromisoformat(repo["pushed_at"].replace("Z", "+00:00")),
        "topics": repo.get("topics", []),
        "fetched_at": fetched_at,
    }
