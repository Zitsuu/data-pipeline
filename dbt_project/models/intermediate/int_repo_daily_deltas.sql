with daily as (

    select
        *,
        lag(stars) over (partition by repo_id order by snapshot_date) as prev_stars,
        lag(forks) over (partition by repo_id order by snapshot_date) as prev_forks,
        lag(open_issues) over (partition by repo_id order by snapshot_date) as prev_open_issues,
        lag(snapshot_date) over (partition by repo_id order by snapshot_date) as prev_snapshot_date
    from {{ ref('int_repos_deduped') }}

)

select
    repo_snapshot_id,
    repo_id,
    full_name,
    owner_login,
    html_url,
    description,
    language,
    topics,
    stars,
    forks,
    open_issues,
    watchers,
    created_at,
    updated_at,
    pushed_at,
    fetched_at,
    snapshot_date,
    repo_age_days,
    days_since_last_push,
    has_description,
    topic_count,
    prev_snapshot_date,
    stars - prev_stars as stars_delta,
    forks - prev_forks as forks_delta,
    open_issues - prev_open_issues as issues_delta
from daily
