{% snapshot repos_snapshot %}
{{
    config(
      target_schema='snapshots',
      unique_key='repo_id',
      strategy='check',
      check_cols=['stars', 'forks', 'description'],
    )
}}

select repo_id, full_name, stars, forks, description, language, fetched_at
from {{ ref('int_repos_deduped') }}

{% endsnapshot %}
