with languages as (

    select distinct language
    from {{ ref('int_repos_deduped') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['language']) }} as language_key,
    language,
    case language
        when 'python' then 'Python'
        when 'typescript' then 'TypeScript'
        when 'javascript' then 'JavaScript'
        when 'rust' then 'Rust'
        when 'go' then 'Go'
        else initcap(language)
    end as language_display_name,
    case
        when language in ('python', 'javascript', 'typescript') then 'high-level'
        when language in ('rust', 'go') then 'systems'
        else 'other'
    end as language_category
from languages
