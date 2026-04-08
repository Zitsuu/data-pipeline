import asyncio
from pathlib import Path

from prefect import flow
from prefect.client.schemas.schedules import CronSchedule


async def register():
    source = str(Path(__file__).resolve().parent.parent)
    entrypoint = "flows/ingest_github.py:ingest_github_trending"

    loaded_flow = await flow.from_source(
        source=source,
        entrypoint=entrypoint,
    )

    deployment_id = await loaded_flow.deploy(
        name="github-trending-hourly",
        work_pool_name="default-pool",
        schedule=CronSchedule(cron="0 * * * *", timezone="Asia/Kolkata"),
        tags=["github", "ingestion", "hourly"],
        description=(
            "Fetches top trending repos across 5 languages from GitHub "
            "and loads into raw.github_trending"
        ),
        parameters={
            "languages": ["python", "typescript", "rust", "go", "javascript"]
        },
        print_next_steps=False,
    )
    print(f"Deployment registered: {deployment_id}")
    return deployment_id


if __name__ == "__main__":
    asyncio.run(register())
