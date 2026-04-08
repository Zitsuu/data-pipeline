with source as (

    select * from {{ source('github_raw', 'github_trending') }}

),

cleaned as (

    select
        -- IDs
        {{ dbt_utils.generate_surrogate_key(['repo_id', 'fetched_at']) }} as repo_snapshot_id,
        repo_id::bigint as repo_id,

        -- Descriptive
        full_name::text as full_name,
        owner_login::text as owner_login,
        html_url::text as html_url,
        description::text as description,
        language::text as language,
        topics::text[] as topics,

        -- Metrics
        stars::integer as stars,
        forks::integer as forks,
        open_issues::integer as open_issues,
        watchers::integer as watchers,

        -- Timestamps
        created_at::timestamptz as created_at,
        updated_at::timestamptz as updated_at,
        pushed_at::timestamptz as pushed_at,
        fetched_at::timestamptz as fetched_at,

        -- Derived
        date_trunc('day', fetched_at)::date as snapshot_date,
        extract(day from (fetched_at - created_at))::int as repo_age_days,
        extract(day from (fetched_at - pushed_at))::int as days_since_last_push,
        (description is not null and description != '') as has_description,
        coalesce(array_length(topics, 1), 0) as topic_count

    from source
    where repo_id is not null
      and stars >= 0

)

select * from cleaned
