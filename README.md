# Data Pipeline — GitHub Trending Repos

![CI](https://github.com/Zitsuu/data-pipeline/actions/workflows/ci.yml/badge.svg)

An end-to-end data engineering pipeline that ingests trending GitHub repositories, transforms the data with dbt, and visualizes insights in Metabase. Orchestrated by Prefect, stored in PostgreSQL, and fully containerized with Docker Compose.

## Architecture

| Service    | Role                              | Port  |
|------------|-----------------------------------|-------|
| PostgreSQL | Data warehouse (raw + analytics)  | 5432  |
| Prefect    | Workflow orchestration            | 4200  |
| Metabase   | Dashboards & visualization        | 3000  |
| dbt        | SQL-based data transformations (+ dbt_utils)  | —     |

## Setup

```bash
# Start infrastructure
docker compose up -d

# Create venv and install dependencies
python -m venv venv
source venv/Scripts/activate   # Windows
pip install -r requirements.txt

# Run smoke tests
pytest tests/test_infrastructure.py -v

# Open Metabase and follow the dashboard setup guide
# http://localhost:3000 → see dashboards/SETUP.md
```

## Data Sources

**GitHub Search API** — fetches trending repositories created in the last 7 days, sorted by stars, across multiple languages (Python, TypeScript, Rust, Go, JavaScript).

- Unauthenticated: 10 requests/minute, 60 requests/hour
- Authenticated (set `GITHUB_TOKEN` in `.env`): 30 requests/minute, 5,000 requests/hour

## Orchestration

The ingestion flow runs as a **Prefect deployment** (`github-trending-hourly`) against the Prefect server in Docker.

- **Schedule:** Every hour on the hour (`0 * * * *`, Asia/Kolkata)
- **Work pool:** `default-pool` (process type)
- **Per run:** 5 languages x 50 repos = up to 250 rows inserted into `raw.github_trending`

### Starting the worker

The worker must run in a **dedicated terminal** for scheduled/triggered runs to execute:

```bash
prefect worker start --pool default-pool
```

### Triggering a manual run

```bash
prefect deployment run "ingest-github-trending/github-trending-hourly"
```

Monitor progress in the Prefect UI at http://localhost:4200.

> **Note:** For production, the worker would be a systemd service (Linux), Windows service, or a containerized worker in the Docker Compose stack. For this portfolio project, the manual terminal approach is sufficient.

## Data Modeling

dbt transforms raw data through three layers:

| Layer        | Schema        | Materialization | Purpose                                  |
|--------------|---------------|-----------------|------------------------------------------|
| **staging**  | `staging`     | view            | Clean, cast, rename, derive basic fields |
| **intermediate** | `intermediate` | view        | Join, aggregate, business logic          |
| **marts**    | `analytics`   | table           | Final tables for dashboards and BI       |

```bash
cd dbt_project
dbt deps          # install dbt_utils
dbt run           # build all models
dbt snapshot      # capture SCD-2 snapshot
dbt test          # run all 28 tests
dbt docs generate && dbt docs serve   # interactive docs at localhost:8080
```

### Star Schema

The marts layer follows a star schema pattern:

```
raw.github_trending
  └─► stg_github__trending_repos    (staging view)
        └─► int_repos_deduped       (deduplicated: 1 row per repo per day)
              ├─► int_repo_daily_deltas  (+ day-over-day star/fork/issue deltas)
              │     └─► fct_repo_daily_snapshots  (fact table)
              │           └─► mart_trending_summary   (pre-aggregated for dashboards)
              ├─► dim_repos              (repo dimension, latest attributes)
              ├─► dim_languages          (language dimension with categories)
              └─► snapshots.repos_snapshot  (SCD-2 tracking stars/forks/description)
```

- **fct_repo_daily_snapshots** — central fact table with one row per repo per day, indexed on `snapshot_date` and `repo_id`, joined to both dimensions
- **dim_repos** — latest known attributes per repo (owner, description, topics)
- **dim_languages** — 5 languages with display names and categories (high-level vs systems)
- **mart_trending_summary** — pre-aggregated by language per day for dashboard queries
- **repos_snapshot** — dbt snapshot (check strategy) tracking changes to stars, forks, and description over time

## Dashboard

Metabase runs at **http://localhost:3000**. See [dashboards/SETUP.md](dashboards/SETUP.md) for a click-by-click setup guide.

| Card | Description | Visualization |
|------|-------------|---------------|
| Top 10 Trending Repos | Highest-starred repos across all languages | Table |
| Fastest Growing Repos | Repos with largest day-over-day star gains | Table |
| Language Popularity Over Time | Total stars per language by date | Line chart |
| Average Stars by Language | Current-day average stars per language | Bar chart |
| Total Repos by Language | Distribution of tracked repos | Pie chart |
| Recently Active Repos | Repos pushed within the last 7 days | Table |

All SQL queries are in [dashboards/queries.sql](dashboards/queries.sql) — portable and version-controlled.

![Dashboard screenshot](dashboards/screenshot.png)

## Continuous Integration

Every push and pull request triggers a **GitHub Actions workflow** that:

1. Spins up a fresh Postgres 16 service container
2. Creates the `raw` and `analytics` schemas and the `raw.github_trending` table
3. Seeds 15 fixture rows (3 per language, spanning 2 days) to exercise delta logic
4. Runs `dbt build` — all 7 models, 28 tests, and 1 snapshot in dependency order
5. Fails loudly if any model or test fails

This proves the entire dbt project is **reproducible on a clean machine** with no dependency on local state or real API data. On failure, dbt logs and target artifacts are uploaded for debugging.

## Status

- [x] **Stage 1** — Project scaffold + Docker Compose infrastructure
- [x] **Stage 2** — GitHub API ingestion with Prefect flow
- [x] **Stage 3** — Scheduled Prefect deployment with worker
- [x] **Stage 4** — dbt project with staging models and tests
- [x] **Stage 5** — Intermediate models, star schema marts, and dbt snapshot
- [x] **Stage 6** — Metabase dashboard setup with 6 analytics cards
- [x] **Stage 7** — GitHub Actions CI with fixture data and dbt build
