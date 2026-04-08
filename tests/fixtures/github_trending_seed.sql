-- Fixture data: 15 rows (3 per language, 2 distinct fetched_at days per language)
-- Satisfies all dbt tests: not_null, accepted_values, stars >= 0, unique combos

INSERT INTO raw.github_trending
    (repo_id, full_name, owner_login, html_url, description, language,
     stars, forks, open_issues, watchers, created_at, updated_at, pushed_at,
     topics, fetched_at)
VALUES
-- Python (3 rows, 2 days)
(100001, 'alice/ml-toolkit', 'alice',
 'https://github.com/alice/ml-toolkit', 'A machine learning toolkit',
 'python', 1200, 340, 12, 1200,
 '2026-03-10T00:00:00Z', '2026-04-06T10:00:00Z', '2026-04-06T09:00:00Z',
 ARRAY['ai','machine-learning']::text[], '2026-04-07 00:00:00+00'),

(100001, 'alice/ml-toolkit', 'alice',
 'https://github.com/alice/ml-toolkit', 'A machine learning toolkit',
 'python', 1250, 345, 14, 1250,
 '2026-03-10T00:00:00Z', '2026-04-07T10:00:00Z', '2026-04-07T09:00:00Z',
 ARRAY['ai','machine-learning']::text[], '2026-04-08 00:00:00+00'),

(100002, 'bob/data-pipeline', 'bob',
 'https://github.com/bob/data-pipeline', 'ETL framework',
 'python', 500, 80, 3, 500,
 '2026-03-15T00:00:00Z', '2026-04-07T12:00:00Z', '2026-04-07T11:00:00Z',
 ARRAY['etl','data']::text[], '2026-04-08 00:00:00+00'),

-- TypeScript (3 rows, 2 days)
(200001, 'carol/ui-lib', 'carol',
 'https://github.com/carol/ui-lib', 'React component library',
 'typescript', 3000, 600, 25, 3000,
 '2026-03-05T00:00:00Z', '2026-04-06T08:00:00Z', '2026-04-06T07:00:00Z',
 ARRAY['react','ui']::text[], '2026-04-07 00:00:00+00'),

(200001, 'carol/ui-lib', 'carol',
 'https://github.com/carol/ui-lib', 'React component library',
 'typescript', 3100, 610, 27, 3100,
 '2026-03-05T00:00:00Z', '2026-04-07T08:00:00Z', '2026-04-07T07:00:00Z',
 ARRAY['react','ui']::text[], '2026-04-08 00:00:00+00'),

(200002, 'dave/cli-tool', 'dave',
 'https://github.com/dave/cli-tool', NULL,
 'typescript', 150, 20, 0, 150,
 '2026-03-20T00:00:00Z', '2026-04-07T06:00:00Z', '2026-04-01T06:00:00Z',
 ARRAY[]::text[], '2026-04-08 00:00:00+00'),

-- Rust (3 rows, 2 days)
(300001, 'eve/fast-parser', 'eve',
 'https://github.com/eve/fast-parser', 'Blazingly fast parser',
 'rust', 800, 90, 5, 800,
 '2026-03-12T00:00:00Z', '2026-04-06T14:00:00Z', '2026-04-06T13:00:00Z',
 ARRAY['parser','performance']::text[], '2026-04-07 00:00:00+00'),

(300001, 'eve/fast-parser', 'eve',
 'https://github.com/eve/fast-parser', 'Blazingly fast parser',
 'rust', 850, 95, 4, 850,
 '2026-03-12T00:00:00Z', '2026-04-07T14:00:00Z', '2026-04-07T13:00:00Z',
 ARRAY['parser','performance']::text[], '2026-04-08 00:00:00+00'),

(300002, 'frank/wasm-runtime', 'frank',
 'https://github.com/frank/wasm-runtime', 'WebAssembly runtime',
 'rust', 2200, 180, 8, 2200,
 '2026-03-08T00:00:00Z', '2026-04-07T16:00:00Z', '2026-04-07T15:00:00Z',
 ARRAY['wasm','runtime']::text[], '2026-04-08 00:00:00+00'),

-- Go (3 rows, 2 days)
(400001, 'grace/micro-svc', 'grace',
 'https://github.com/grace/micro-svc', 'Microservice framework',
 'go', 650, 110, 7, 650,
 '2026-03-18T00:00:00Z', '2026-04-06T09:00:00Z', '2026-04-06T08:00:00Z',
 ARRAY['microservices','go']::text[], '2026-04-07 00:00:00+00'),

(400001, 'grace/micro-svc', 'grace',
 'https://github.com/grace/micro-svc', 'Microservice framework',
 'go', 700, 115, 6, 700,
 '2026-03-18T00:00:00Z', '2026-04-07T09:00:00Z', '2026-04-07T08:00:00Z',
 ARRAY['microservices','go']::text[], '2026-04-08 00:00:00+00'),

(400002, 'henry/k8s-tool', 'henry',
 'https://github.com/henry/k8s-tool', 'Kubernetes helper',
 'go', 0, 0, 0, 0,
 '2026-04-01T00:00:00Z', '2026-04-07T10:00:00Z', '2026-04-07T09:00:00Z',
 ARRAY['kubernetes']::text[], '2026-04-08 00:00:00+00'),

-- JavaScript (3 rows, 2 days)
(500001, 'iris/chart-lib', 'iris',
 'https://github.com/iris/chart-lib', 'Charting library',
 'javascript', 5000, 1200, 45, 5000,
 '2026-03-01T00:00:00Z', '2026-04-06T11:00:00Z', '2026-04-06T10:00:00Z',
 ARRAY['charts','visualization']::text[], '2026-04-07 00:00:00+00'),

(500001, 'iris/chart-lib', 'iris',
 'https://github.com/iris/chart-lib', 'Charting library',
 'javascript', 5200, 1220, 43, 5200,
 '2026-03-01T00:00:00Z', '2026-04-07T11:00:00Z', '2026-04-07T10:00:00Z',
 ARRAY['charts','visualization']::text[], '2026-04-08 00:00:00+00'),

(500002, 'jack/form-validator', 'jack',
 'https://github.com/jack/form-validator', 'Form validation library',
 'javascript', 300, 50, 2, 300,
 '2026-03-22T00:00:00Z', '2026-04-07T07:00:00Z', '2026-04-07T06:00:00Z',
 ARRAY['forms','validation']::text[], '2026-04-08 00:00:00+00');
