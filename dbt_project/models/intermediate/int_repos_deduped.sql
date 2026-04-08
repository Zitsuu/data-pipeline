with ranked as (

    select
        *,
        row_number() over (
            partition by repo_id, snapshot_date
            order by fetched_at desc
        ) as rn
    from {{ ref('stg_github__trending_repos') }}

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
    topic_count
from ranked
where rn = 1
