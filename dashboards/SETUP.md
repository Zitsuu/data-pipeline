# Metabase Dashboard Setup

Step-by-step guide to build the **GitHub Trending Overview** dashboard in Metabase.

Prerequisites: Docker Compose stack is running (`docker compose up -d`), dbt models are built (`dbt run`), and data has been ingested at least once.

---

## A. Initial Metabase Setup (First Launch Only)

1. Open **http://localhost:3000** in your browser
2. Click **Let's get started**
3. Select your preferred language, click **Next**
4. Create an admin account:
   - First name: `Admin`
   - Last name: `User`
   - Email: `admin@pipeline.local`
   - Password: choose something (do NOT commit this)
   - Click **Next**
5. On "What will you use Metabase for?" pick any option, click **Next**
6. On "Add your data" — click **I'll add my data later** (we'll add it in the next step)
7. On usage data preferences — uncheck if desired, click **Finish**
8. Click **Take me to Metabase**

---

## B. Connect to PostgreSQL

1. Click the **gear icon** (top-right) → **Admin Settings**
2. Click **Databases** in the left sidebar
3. Click **Add database** (top-right)
4. Fill in:
   - **Database type:** PostgreSQL
   - **Display name:** `GitHub Pipeline Warehouse`
   - **Host:** `postgres` *(NOT localhost — Metabase runs inside Docker, use the Docker service name)*
   - **Port:** `5432`
   - **Database name:** `warehouse`
   - **Username:** `pipeline`
   - **Password:** `pipeline_dev_pw`
5. Expand **"Choose when syncs and scans happen"** (optional):
   - Under "Only these schemas", check `analytics` to restrict visible schemas
6. Click **Save**
7. Wait for the sync to complete (green checkmark appears, ~10 seconds)
8. Click the Metabase logo (top-left) to return to the home screen

---

## C. Create the 6 Question Cards

For **each** card below, repeat this process:

1. Click **+ New** (top-right) → **SQL query**
2. In the database dropdown (top-left of editor), select **GitHub Pipeline Warehouse**
3. Paste the SQL from `dashboards/queries.sql` for that card
4. Click the **blue Run** button (or Ctrl+Enter) to verify results
5. Change the visualization type as noted below
6. Click **Save** (top-right)
7. Name it exactly as shown below
8. Save to collection: **+ New collection** → name it `GitHub Pipeline` (first time only)

### Card 1: Top 10 Trending Repos

```sql
-- Paste the "Card 1" query from queries.sql
```

- **Visualization:** Table (default)
- **Save as:** `Top 10 Trending Repos`
- **Tip:** Click on column headers to sort. You can click the **gear icon** on the visualization to hide the `html_url` column or make it a clickable link.

### Card 2: Fastest Growing Repos

```sql
-- Paste the "Card 2" query from queries.sql
```

- **Visualization:** Table
- **Save as:** `Fastest Growing Repos`
- **Note:** Shows stars_delta = 0 until data spans multiple days. Once deltas appear, the ranking becomes meaningful.

### Card 3: Language Popularity Over Time

```sql
-- Paste the "Card 3" query from queries.sql
```

- **Visualization:** Click **Visualization** → choose **Line**
  - X-axis: `snapshot_date`
  - Y-axis: `total_stars`
  - Series: `language` (Metabase usually auto-detects this)
- **Save as:** `Language Popularity Over Time`
- **Note:** With only 1 day of data this shows dots; it becomes a line chart once you have 2+ days.

### Card 4: Average Stars by Language

```sql
-- Paste the "Card 4" query from queries.sql
```

- **Visualization:** Click **Visualization** → choose **Bar**
  - X-axis: `language`
  - Y-axis: `avg_stars`
- **Save as:** `Average Stars by Language`

### Card 5: Total Repos by Language

```sql
-- Paste the "Card 5" query from queries.sql
```

- **Visualization:** Click **Visualization** → choose **Pie** (or **Donut**)
  - Dimension: `language`
  - Measure: `repo_count`
- **Save as:** `Total Repos by Language`

### Card 6: Recently Active Repos

```sql
-- Paste the "Card 6" query from queries.sql
```

- **Visualization:** Table
- **Save as:** `Recently Active Repos`

---

## D. Assemble the Dashboard

1. Click **+ New** (top-right) → **Dashboard**
2. Name: `GitHub Trending Overview`
3. Collection: `GitHub Pipeline`
4. Click **Create**
5. You're now in edit mode. Click **the filter/pencil icon** if not already in edit mode.
6. Click **+ (Add)** → **Saved question** → select each card from the `GitHub Pipeline` collection

### Suggested Layout

```
┌──────────────────────────┬──────────────────────────┐
│  Top 10 Trending Repos   │  Fastest Growing Repos   │
│  (Card 1 — wide table)   │  (Card 2 — wide table)   │
├──────────────────────────┴──────────────────────────┤
│        Language Popularity Over Time                 │
│        (Card 3 — full-width line chart)              │
├──────────┬──────────┬───────────────────────────────┤
│ Avg Stars│ Repos by │   Recently Active Repos       │
│ by Lang  │ Language │   (Card 6 — table)            │
│ (Card 4) │ (Card 5) │                               │
│  bar     │  pie     │                               │
└──────────┴──────────┴───────────────────────────────┘
```

- **Drag and resize** cards to match the layout above
- Cards snap to a grid — drag edges to resize
- Click **Save** when done

---

## E. Optional Polish

### Add a title card
1. In dashboard edit mode, click **+ (Add)** → **Text**
2. Type: `# GitHub Trending Repos Dashboard`
3. Add a subtitle: `Tracking trending repositories across Python, TypeScript, Rust, Go, and JavaScript`
4. Drag it to the very top of the dashboard

### Set auto-refresh
1. Click the **clock icon** in the top-right of the dashboard
2. Select **1 hour** to match the ingestion schedule

### Add filters (stretch goal)
1. In edit mode, click **Filter** → **Time** → **Date picker**
2. Map it to the `snapshot_date` column in Cards 1, 2, 3, 4, 6
3. Add another filter: **Category** for `language`
4. Map it to the `language` column in all cards
5. Click **Save**

---

## Verification

After setup, you should see:
- 6 cards on the dashboard with real data
- Bar chart showing Python with highest avg stars
- Pie chart with roughly equal slices (~50 repos per language)
- Tables with clickable repo names

The dashboard auto-refreshes hourly. To manually refresh, click the **refresh icon** (top-right of dashboard).
