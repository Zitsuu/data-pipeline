# Exporting the Metabase Dashboard

## Screenshot (Recommended for README)

1. Open the dashboard at **http://localhost:3000**
2. Navigate to the `GitHub Pipeline` collection → `GitHub Trending Overview`
3. Take a full-page screenshot:
   - **Windows:** Win + Shift + S → select region, or use browser DevTools (F12 → Ctrl+Shift+P → "Capture full size screenshot")
   - **Browser extension:** GoFullPage, Fireshot, or similar
4. Save as `dashboards/screenshot.png`
5. Commit the screenshot — it's referenced in README.md

## Exporting Individual Cards

Each card can be downloaded individually:
1. Open a card → click the **download icon** (bottom-right)
2. Choose format: PNG, CSV, XLSX, or JSON

## SQL Queries

All dashboard queries are saved in `dashboards/queries.sql`. These serve as the portable, version-controlled definition of what each card shows — independent of Metabase.

## Full Metabase Serialization

Metabase's serialization feature (export/import of dashboards, questions, and collections as YAML) is available only on the **Pro/Enterprise plan**.

For this open-source setup, the recommended approach is:
- Keep `dashboards/queries.sql` as the source of truth for card logic
- Keep `dashboards/SETUP.md` as the reproducible setup guide
- Keep `dashboards/screenshot.png` as the visual reference
- If you need to recreate the dashboard, follow SETUP.md — it takes ~5 minutes

## Metabase API (Alternative)

Metabase has a REST API that can be used to programmatically create questions and dashboards. This is possible but complex for a portfolio project. The manual approach documented in SETUP.md is simpler and more maintainable.
