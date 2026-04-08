import asyncio
from datetime import datetime, timezone

from prefect.client.orchestration import get_client


async def _get_recent_runs(deployment_name: str, limit: int = 10) -> list[dict]:
    async with get_client() as client:
        deployments = await client.read_deployments()
        deployment = next(
            (d for d in deployments if d.name == deployment_name), None
        )
        if deployment is None:
            raise ValueError(f"Deployment '{deployment_name}' not found")

        runs = await client.read_flow_runs(
            deployment_filter={"id": {"any_": [str(deployment.id)]}},
            sort="START_TIME_DESC",
            limit=limit,
        )

        results = []
        for run in runs:
            start = run.start_time
            end = run.end_time
            duration = None
            if start and end:
                duration = (end - start).total_seconds()

            results.append({
                "name": run.name,
                "state": str(run.state.type.value) if run.state else None,
                "start_time": start,
                "end_time": end,
                "duration_seconds": duration,
            })

        return results


def get_recent_runs(deployment_name: str, limit: int = 10) -> list[dict]:
    return asyncio.run(_get_recent_runs(deployment_name, limit))
