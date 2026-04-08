{{
    config(
        indexes=[
            {'columns': ['snapshot_date'], 'type': 'btree'},
            {'columns': ['repo_id'], 'type': 'btree'},
        ]
    )
}}

select
    d.repo_snapshot_id,
    d.repo_id,
    dl.language_key,
    d.snapshot_date,
    d.stars,
    d.forks,
    d.open_issues,
    d.watchers,
    d.stars_delta,
    d.forks_delta,
    d.issues_delta,
    d.repo_age_days,
    d.days_since_last_push,
    d.fetched_at
from {{ ref('int_repo_daily_deltas') }} d
inner join {{ ref('dim_repos') }} dr
    on d.repo_id = dr.repo_id
inner join {{ ref('dim_languages') }} dl
    on d.language = dl.language
