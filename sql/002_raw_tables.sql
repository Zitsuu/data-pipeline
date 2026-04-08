CREATE TABLE IF NOT EXISTS raw.github_trending (
    repo_id       BIGINT       NOT NULL,
    full_name     TEXT         NOT NULL,
    owner_login   TEXT         NOT NULL,
    html_url      TEXT         NOT NULL,
    description   TEXT,
    language      TEXT         NOT NULL,
    stars         INTEGER      NOT NULL,
    forks         INTEGER      NOT NULL,
    open_issues   INTEGER      NOT NULL,
    watchers      INTEGER      NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL,
    updated_at    TIMESTAMPTZ  NOT NULL,
    pushed_at     TIMESTAMPTZ  NOT NULL,
    topics        TEXT[]       NOT NULL DEFAULT '{}',
    fetched_at    TIMESTAMPTZ  NOT NULL,
    PRIMARY KEY (repo_id, fetched_at)
);

CREATE INDEX IF NOT EXISTS idx_github_trending_lang_fetched
    ON raw.github_trending (language, fetched_at DESC);
