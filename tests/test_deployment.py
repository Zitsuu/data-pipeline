import asyncio

import pytest
from prefect.client.orchestration import get_client


@pytest.mark.integration
def test_deployment_exists():
    async def _check():
        async with get_client() as client:
            deployments = await client.read_deployments()
            names = [d.name for d in deployments]
            assert "github-trending-hourly" in names

    asyncio.run(_check())


@pytest.mark.integration
def test_deployment_schedule():
    async def _check():
        async with get_client() as client:
            deployments = await client.read_deployments()
            dep = next(d for d in deployments if d.name == "github-trending-hourly")
            schedules = dep.schedules
            assert len(schedules) >= 1
            schedule = schedules[0].schedule
            assert schedule.cron == "0 * * * *"

    asyncio.run(_check())


@pytest.mark.integration
def test_deployment_work_pool():
    async def _check():
        async with get_client() as client:
            deployments = await client.read_deployments()
            dep = next(d for d in deployments if d.name == "github-trending-hourly")
            assert dep.work_pool_name == "default-pool"

    asyncio.run(_check())
