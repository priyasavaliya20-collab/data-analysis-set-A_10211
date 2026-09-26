# 📦 Delivery Delay Analysis

**Student:** [Your Name] — [Student ID]
**Assigned Set:** Set A (`data-analysis-set-A_10211`)
**Repo:** https://github.com/priyasavaliya20-collab/data-analysis-set-A_10211

---

## 🛠️ Tools Used

<div>

<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/Jupyter-Notebook-F37626?style=for-the-badge&logo=jupyter&logoColor=white"/>
<img src="https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white"/>
<img src="https://img.shields.io/badge/Matplotlib-11557C?style=for-the-badge"/>
<img src="https://img.shields.io/badge/SQL-PostgreSQL%2FMySQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white"/>
<img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white"/>
<img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black"/>

</div>

---

## 🎯 Objective

Delivery performance across four routes (`R1`–`R4`) and four hubs (Ahmedabad, Chennai, Delhi, Mumbai) has been inconsistent over Jan–Mar, and management wants a clear, evidence-backed picture of **where** delay is concentrated and **why**, so that corrective action — route review, hub staffing, or SLA renegotiation — can be prioritized instead of applied uniformly.

To make the analysis auditable, the same underlying dataset is independently processed in **four different tools** (SQL, Python, Excel, Power BI), and the results are cross-checked against each other in Section 13 so that any single-tool error would be caught rather than silently reported as fact.

**Business questions answered:**
1. Which service type (Express vs. Standard) and which specific routes/hubs account for the most delay, and by how much?
2. Are delays trending up or down month over month, and which routes cross a "significant delay" threshold (>8 total delay days)?

---

## ♻️ Workflow

```
Raw CSVs (deliveries.csv + routes.csv)
        │
        ▼
  Inspect: shape, nulls, dtypes
        │
        ▼
  Clean: drop duplicate record_id 12  (13 rows → 12 rows)
        │
        ▼
  Merge: LEFT JOIN deliveries ⨝ routes  ON route_id
        │
        ▼
  Derive: delay_days = MAX(actual − promised, 0)
          is_delayed = actual > promised
        │
        ▼
  ┌─────────────┬─────────────┬─────────────┬─────────────┐
  │     SQL     │    Python   │    Excel    │  Power BI   │
  │ setup.sql → │  pandas →   │ Raw→Lookup→ │  dashboard  │
  │ queries.sql │  clean_data │ Clean→Summ. │  (KPIs)     │
  └─────────────┴─────────────┴─────────────┴─────────────┘
        │
        ▼
  Reconcile one aggregate value across all 4 tools (Section 13)
        │
        ▼
  Findings + Recommendation (Section 11)
```

1. **Data Understanding** — load both raw files, inspect shape/nulls/dtypes for each
2. **Cleaning** — remove the one exact duplicate row, left-join on `route_id`, assert no unmatched routes
3. **Metric Derivation** — compute `delay_days` and `is_delayed` on the merged table
4. **Parallel Analysis** — the same cleaned logic is re-implemented natively in SQL, Python, Excel, and Power BI
5. **Reconciliation** — one shared aggregate (total delay days) is compared across all four tools; any mismatch is explained, not hidden
6. **Reporting** — findings condensed into two numeric insights and one actionable recommendation

---

## 📂 Project Files

| 📄 File | 📌 Description |
|---|---|
| `Data/deliveries.csv` | Raw dataset — 13 rows (contains 1 exact duplicate, `record_id 12`) |
| `Data/routes.csv` | Route master — 4 routes with `route_name`, `service_type` |
| `Data/clean_data.csv` | Cleaned & merged dataset — 12 rows, used as the common input for all four tools |
| `sql/setup.sql` | Creates & seeds the `routes` and `deliveries` tables |
| `sql/queries.sql` | 5 queries — delay by service type, routes with >8 delay days, top-2 hubs, unmatched-route check, row counts |
| `sql/output/*.csv` | Exported results of each `queries.sql` query, for reference without re-running SQL |
| `python/Delivery_Delay_Analysis.ipynb` | Full notebook — load, clean, merge, derive metrics, chart monthly delay trend |
| `python/python_summary.csv` | Service-type summary exported from the notebook |
| `python/python_chart.png` | Monthly total-delay bar chart exported from the notebook |
| `excel/analysis.xlsx` | `Raw` / `Lookup` / `Clean` / `Summary` sheets, with a PivotTable |
| `powerbi/dashboard.pbix` | Interactive dashboard — KPIs, delay by service type, monthly trend, hub filter |

---

## 🧬 Dataset Structure

| Attribute | Detail |
|---|---|
| Raw shape | 13 rows × 6 columns |
| Cleaned shape | 12 rows × 10 columns (after dedup + merge + derived fields) |
| Missing values | None across all columns |
| Duplicate found | `record_id 12` (`Mar, R4, Mumbai, 6, 15`) — exact duplicate row, dropped during cleaning |
| Target metric | `delay_days` (derived, not present in raw data) |
| Key columns | `route_id`, `hub`, `service_type`, `promised_days`, `actual_days` |
| Time span | 3 months — Jan, Feb, Mar |
| Routes covered | `R1` Metro Link (Express), `R2` City Dash (Express), `R3` Highway Freight (Standard), `R4` Rural Feeder (Standard) |
| Hubs covered | Ahmedabad, Chennai, Delhi, Mumbai |

**Data dictionary**

| Column | Type | Present in | Meaning |
|---|---|---|---|
| `record_id` | int | raw, clean | Unique delivery record ID |
| `month` | string | raw, clean | Delivery month (Jan / Feb / Mar) |
| `route_id` | string | raw, clean | Foreign key → `routes.route_id` |
| `hub` | string | raw, clean | Origin/handling hub |
| `promised_days` | int | raw, clean | SLA-promised transit days |
| `actual_days` | int | raw, clean | Actual transit days taken |
| `route_name` | string | clean only | Human-readable route name, joined from `routes` |
| `service_type` | string | clean only | Express / Standard, joined from `routes` |
| `delay_days` | int | clean only | `MAX(actual_days − promised_days, 0)` |
| `is_delayed` | bool | clean only | `actual_days > promised_days` |

---

## 🧹 Cleaning Steps & Metric Definitions

```python
# 1. Type check — both promised_days and actual_days confirmed int64, no coercion needed
print(deliveries['promised_days'].dtype, deliveries['actual_days'].dtype)

# 2. Drop the exact duplicate row (record_id 12 appeared twice)
deliveries = deliveries.drop_duplicates()          # 13 rows → 12 rows

# 3. Left-join onto route master data
df = deliveries.merge(routes, on='route_id', how='left')
assert len(df) == 12
assert df['service_type'].isna().sum() == 0        # confirms every route_id matched

# 4. Derive the two analysis fields
df['delay_days'] = (df['actual_days'] - df['promised_days']).clip(lower=0)
df['is_delayed'] = df['actual_days'] > df['promised_days']
```

**Metric definitions used consistently across all four tools:**
- **`delay_days`** = `MAX(actual_days − promised_days, 0)` — a delivery that arrives early or on time contributes 0, never a negative number
- **Delay incidence rate** = `delayed_records / total_records × 100` — the % of deliveries that missed their promised date at all, regardless of by how much

💡 **Insight:** The single duplicate row is the entire explanation for the mismatch found later in the cross-tool reconciliation (Section 13) — every tool that dedupes before aggregating agrees exactly; the one tool that doesn't, doesn't.

---

## 🐘 SQL — Setup & Run

```bash
psql -U <user> -d <db> -f sql/setup.sql     # 1. creates & seeds tables — run first
psql -U <user> -d <db> -f sql/queries.sql   # 2. runs the 5 analysis queries, in order
```

`setup.sql` drops and recreates `routes` and `deliveries` with a foreign key from `deliveries.route_id → routes.route_id`, then seeds the same 12 clean records used by every other tool. `queries.sql` then runs five queries in sequence:

| # | Query | Result |
|---|---|---|
| 1 | Total `delay_days` (via `GREATEST`) grouped by `service_type` | Standard = 21, Express = 12 |
| 2 | Total `delay_days` per route, `HAVING SUM(...) > 8` | R4 Rural Feeder = 16, R1 Metro Link = 9 |
| 3 | Total `delay_days` per hub, top 2 | Mumbai = 22, Delhi = 6 |
| 4 | `LEFT JOIN` unmatched-route check | 0 unmatched rows — every `route_id` resolves |
| 5 | Row counts | 12 delivery rows, 4 route rows |

💡 **Insight:** Query 1's **Standard = 21, Express = 12** matches Python and Excel exactly on the deduped 12-row table — the first confirmation point in the reconciliation chain. Query 2 also confirms only **two** routes (R4, R1) cross the >8-day significant-delay threshold; R2 and R3 stay under it.

---

## 🐍 Python — Setup & Run

```bash
pip install -r requirements.txt
python python/analysis.py
# or, interactively:
jupyter notebook python/Delivery_Delay_Analysis.ipynb
```

- **Python:** 3.13.5 · **Packages:** `pandas`, `matplotlib`
- The notebook runs in three parts, top to bottom:

**P1 — Load, Clean & Merge**
```python
deliveries = pd.read_csv('deliveries.csv')
routes = pd.read_csv('routes.csv')
deliveries = deliveries.drop_duplicates()
df = deliveries.merge(routes, on='route_id', how='left')
```
💡 Confirms 13 → 12 rows after dedup, and 0 unmatched `service_type` values after the join.

**P2 — Derived Field & Service-Type Analysis**
```python
df['delay_days'] = (df['actual_days'] - df['promised_days']).clip(lower=0)
df['is_delayed'] = df['actual_days'] > df['promised_days']
service_summary = df.groupby('service_type').agg(
    total_delay_days=('delay_days', 'sum'),
    delayed_records=('is_delayed', 'sum'),
    total_records=('record_id', 'count')
)
```
💡 Both service types land on an identical **66.67% delay incidence rate** despite very different total delay-day counts (Standard 21 vs. Express 12) — Standard's problem is delay *severity* per incident, not delay *frequency*.

**P3 — Monthly Total Delay Chart**
```python
month_order = ['Jan', 'Feb', 'Mar']
monthly_delay = df.groupby('month')['delay_days'].sum().reindex(month_order)
plt.bar(monthly_delay.index, monthly_delay.values)
plt.savefig('python_chart.png')
df.to_csv('clean_data.csv', index=False)
service_summary.to_csv('python_summary.csv', index=False)
```
💡 Total delay days climb every month: **Jan = 7 → Feb = 9 → Mar = 17** — more than doubling from Jan to Mar, the clearest early-warning signal in the whole dataset.

---

## 📊 Excel Sheet Guide

| Sheet | Purpose |
|---|---|
| `Raw` | Original 13-row delivery data, untouched, with a row-count cell for reference |
| `Lookup` | Route master (`route_id`, `route_name`, `service_type`) — VLOOKUP source for the `Clean` sheet |
| `Clean` | Deduplicated + merged data with `delay_days`; a "Cleaning Check" block documents Before Row Count = 13, After Row Count = 12, Duplicate Removed = 1 |
| `Summary` | Hub delay totals (all 4 hubs) plus a PivotTable of delay days by `service_type` × `month` |

💡 **Insight:** The `Summary` PivotTable breaks delay down by month *and* service type in one view — Express delay rises 1 → 3 → 8 across Jan/Feb/Mar, and Standard rises 6 → 6 → 9. Express is growing proportionally faster even though its Mar total is still lower than Standard's.

---

## ⚡ Power BI — Dashboard & Data-Source Refresh

The dashboard shows 3 KPI cards (Delivery Count, Total Delay Days, Delay Incidence Rate), a hub filter panel, a bar chart of delay by `service_type`, and an area chart of delay by month — all built on the **raw, un-deduplicated** 13-row extract (see Section 13 for why this matters).

**Refresh instructions after cloning the repo:**
1. Open `powerbi/dashboard.pbix` in Power BI Desktop.
2. **Home → Transform Data → Data Source Settings**.
3. Select the CSV source → **Change Source** → point to the new local path for `clean_data.csv` (or `deliveries.csv`, matching whichever the report was built on) after cloning.
4. **Close & Apply**, then **Refresh** on the Home ribbon.
5. Confirm the KPI cards recalculate — if the report was pointed at `deliveries.csv`, Total Delay Days should read 42; if repointed at the deduped `clean_data.csv`, it will read 33.

---

## 📈 Results & Insights

**By service type**

| Service Type | Total Delay Days | Delayed Records | Delay Incidence Rate |
|---|---|---|---|
| Express | 12 | 4 / 6 | 66.67% |
| Standard | 21 | 4 / 6 | 66.67% |

**By route**

| Route | Name | Service Type | Total Delay Days | Significant (>8)? |
|---|---|---|---|---|
| R1 | Metro Link | Express | 9 | ✅ Yes |
| R2 | City Dash | Express | 3 | No |
| R3 | Highway Freight | Standard | 5 | No |
| R4 | Rural Feeder | Standard | 16 | ✅ Yes |

**By hub**

| Hub | Total Delay Days |
|---|---|
| Mumbai | 22 |
| Delhi | 6 |
| Chennai | 5 |
| Ahmedabad | 0 |

**By month**

| Month | Total Delay Days |
|---|---|
| Jan | 7 |
| Feb | 9 |
| Mar | 17 |

**Key findings:**
1. **Standard service delays nearly 2× Express**: 21 total delay days vs. 12 for Express (33 total, on cleaned data) — yet both have the exact same 66.67% incidence rate, so Standard's issue is severity, not frequency.
2. **Mumbai hub drives delay concentration**: 22 of the 33 total delay days (≈67%) trace back to Mumbai alone — the next-highest hub (Delhi) has only 6, and Ahmedabad has zero.
3. Route `R4` (Rural Feeder, Standard) is the single biggest contributor at 16 delay days and, combined with R1, is one of only two routes crossing the >8-day significant-delay threshold.
4. Delay is accelerating, not steady: total monthly delay more than doubles from Jan (7) to Mar (17).

**📌 Recommendation:** Prioritize a service-level review of the **Rural Feeder (R4) route and Mumbai hub** operations first — together they explain the bulk of total delay (R4 alone is ~48% of all delay days, Mumbai alone is ~67%), and the Jan→Mar acceleration suggests the underlying cause is worsening rather than stable, making this the highest-leverage, most time-sensitive fix available.

---

## 🔁 Cross-Tool Reconciliation

**Metric:** Total delay days (all records)

| Tool | Value | Basis |
|---|---|---|
| Python | 33 | Cleaned data (12 rows, dedup applied) |
| SQL | 33 | `queries.sql` Q1, summed over cleaned `deliveries` table (12 rows) |
| Excel | 33 | `Clean` sheet, post-dedup |
| Power BI | 42 | Raw 13-row source (duplicate `record_id 12` not removed) |

**Rounding/discrepancy note:** No rounding differences anywhere — the gap is entirely due to Power BI's dashboard being built on the raw 13-row extract rather than `clean_data.csv`. Its total (42) and delay incidence rate (69.23%) both include the duplicate `record_id 12` row twice. Python, SQL, and Excel all dedupe *before* aggregating and agree exactly at **33 total delay days (66.67% incidence)**. Repointing the Power BI source to `clean_data.csv` per the refresh steps above would bring it in line with the other three tools.

---

## 📌 Expected Outcomes

- A single, reconciled delay figure that all four tools agree on, with the one discrepancy fully traced to its root cause
- A route- and hub-level breakdown precise enough to justify targeting Mumbai and R4 specifically, rather than a blanket policy change
- A reusable cleaning/metric pipeline (`delay_days`, `is_delayed`, incidence rate) that can be re-run on future months' data without modification

## 🚀 Suggested Next Steps

- Extend the dataset beyond 3 months to confirm whether the Jan→Mar acceleration is a genuine trend or seasonal noise
- Investigate operationally *why* Mumbai and R4 underperform (carrier, distance, handling capacity) rather than just *that* they do
- Repoint the Power BI source to `clean_data.csv` so all four tools report from the same deduplicated baseline going forward

---

## ⚙️ Installation & Setup

```bash
git clone https://github.com/priyasavaliya20-collab/data-analysis-set-A_10211.git
cd data-analysis-set-A_10211
pip install -r requirements.txt
```

## 📂 Project Structure

```
data-analysis-set-A_10211/
├── README.md
├── requirements.txt
├── Data/
│   ├── deliveries.csv
│   ├── routes.csv
│   └── clean_data.csv
├── sql/
│   ├── setup.sql
│   ├── queries.sql
│   └── output/
│       ├── s2a_delay_by_service_type_csv.csv
│       ├── s2b_routes_significant_delay.csv
│       ├── s2c_top_two_hubs.csv
│       └── s3_unmatched_route_check.csv
├── python/
│   ├── Delivery_Delay_Analysis.ipynb
│   ├── analysis.py
│   ├── python_summary.csv
│   └── python_chart.png
├── excel/
│   └── analysis.xlsx
└── powerbi/
    └── dashboard.pbix
```

---

## 🎬 Project Demo

📹 **Video URL:** [add your video link]
⏱️ **Duration:** [add duration]

---

## 📚 References

No external code or resources were used beyond standard documentation for pandas, matplotlib, SQL, Excel, and Power BI.

---

## ✍️ Authorship Declaration

All work in this repository is my own except where cited.

---

⭐ If this analysis was useful, feel free to star the repository.
