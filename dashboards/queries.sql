-- ============================================================
-- Metabase Dashboard: GitHub Trending Overview
-- These queries run against the analytics schema marts.
-- Paste each into Metabase as a Native Query.
-- ============================================================

-- Card 1: Top 10 Trending Repos (All Time)
-- Visualization: Table
SELECT
    dr.full_name,
    dl.language_display_name AS language,
    f.stars,
    f.forks,
    dr.html_url
FROM analytics.fct_repo_daily_snapshots f
JOIN analytics.dim_repos dr ON f.repo_id = dr.repo_id
JOIN analytics.dim_languages dl ON f.language_key = dl.language_key
WHERE f.snapshot_date = (SELECT MAX(snapshot_date) FROM analytics.fct_repo_daily_snapshots)
ORDER BY f.stars DESC
LIMIT 10;


-- Card 2: Fastest Growing Repos (Stars Delta, Last 24h)
-- Visualization: Table
-- Note: Returns rows only when data spans multiple days.
-- Falls back to top repos by absolute stars when no deltas exist yet.
SELECT
    dr.full_name,
    dl.language_display_name AS language,
    f.stars,
    COALESCE(f.stars_delta, 0) AS stars_delta,
    dr.html_url
FROM analytics.fct_repo_daily_snapshots f
JOIN analytics.dim_repos dr ON f.repo_id = dr.repo_id
JOIN analytics.dim_languages dl ON f.language_key = dl.language_key
WHERE f.snapshot_date = (SELECT MAX(snapshot_date) FROM analytics.fct_repo_daily_snapshots)
ORDER BY COALESCE(f.stars_delta, 0) DESC, f.stars DESC
LIMIT 10;


-- Card 3: Language Popularity Over Time
-- Visualization: Line chart (X: snapshot_date, Y: total_stars, Series: language)
SELECT
    snapshot_date,
    language_display_name AS language,
    total_stars
FROM analytics.mart_trending_summary
ORDER BY snapshot_date, total_stars DESC;


-- Card 4: Average Stars by Language (Current Day)
-- Visualization: Bar chart (X: language, Y: avg_stars)
SELECT
    language_display_name AS language,
    avg_stars,
    total_repos
FROM analytics.mart_trending_summary
WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM analytics.mart_trending_summary)
ORDER BY avg_stars DESC;


-- Card 5: Total Repos Tracked by Language
-- Visualization: Pie / Donut chart
SELECT
    dl.language_display_name AS language,
    COUNT(*) AS repo_count
FROM analytics.dim_repos dr
JOIN analytics.dim_languages dl ON dr.language_key = dl.language_key
GROUP BY dl.language_display_name
ORDER BY repo_count DESC;


-- Card 6: Recently Active Repos (Pushed Within Last 7 Days)
-- Visualization: Table
SELECT
    dr.full_name,
    dl.language_display_name AS language,
    f.stars,
    f.days_since_last_push
FROM analytics.fct_repo_daily_snapshots f
JOIN analytics.dim_repos dr ON f.repo_id = dr.repo_id
JOIN analytics.dim_languages dl ON f.language_key = dl.language_key
WHERE f.snapshot_date = (SELECT MAX(snapshot_date) FROM analytics.fct_repo_daily_snapshots)
  AND f.days_since_last_push <= 7
ORDER BY f.stars DESC
LIMIT 20;
