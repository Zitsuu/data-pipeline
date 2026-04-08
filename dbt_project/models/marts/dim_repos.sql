with latest as (

    select
        *,
        row_number() over (
            partition by repo_id
            order by snapshot_date desc
        ) as rn
    from {{ ref('int_repos_deduped') }}

),

repos as (

    select
        repo_id,
        full_name,
        owner_login,
        html_url,
        description,
        language,
        created_at,
        topics,
        topic_count,
        has_description
    from latest
    where rn = 1

)

select
    r.repo_id,
    r.full_name,
    r.owner_login,
    r.html_url,
    r.description,
    r.language,
    dl.language_key,
    r.created_at,
    r.topics,
    r.topic_count,
    r.has_description
from repos r
left join {{ ref('dim_languages') }} dl
    on r.language = dl.language
