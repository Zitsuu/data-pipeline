with daily_stats as (

    select
        f.snapshot_date,
        f.language_key,
        count(*) as total_repos,
        sum(f.stars) as total_stars,
        avg(f.stars)::int as avg_stars,
        max(f.stars) as max_stars,
        coalesce(sum(f.stars_delta), 0) as total_stars_delta,
        count(*) filter (where f.stars_delta is null) as new_repos_count,
        first_value(f.repo_id) over (
            partition by f.snapshot_date, f.language_key
            order by f.stars desc
        ) as top_repo_id
    from {{ ref('fct_repo_daily_snapshots') }} f
    group by f.snapshot_date, f.language_key, f.repo_id, f.stars

),

summarized as (

    select
        snapshot_date,
        language_key,
        sum(total_repos) as total_repos,
        sum(total_stars) as total_stars,
        avg(avg_stars)::int as avg_stars,
        max(max_stars) as max_stars,
        sum(total_stars_delta) as total_stars_delta,
        sum(new_repos_count) as new_repos_count,
        (array_agg(top_repo_id order by max_stars desc))[1] as top_repo_id
    from daily_stats
    group by snapshot_date, language_key

)

select
    s.snapshot_date,
    s.language_key,
    dl.language,
    dl.language_display_name,
    s.total_repos,
    s.total_stars,
    s.avg_stars,
    s.max_stars,
    s.total_stars_delta,
    s.new_repos_count,
    s.top_repo_id
from summarized s
inner join {{ ref('dim_languages') }} dl
    on s.language_key = dl.language_key
