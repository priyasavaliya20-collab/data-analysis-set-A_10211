
# 📦 Delivery Delay Analysis

**Student:** [Your Name] — [Student ID]
**Assigned Set:** Set A (`data-analysis-set-A_10211`)
**Repo:** https://github.com/priyasavaliya20-collab/data-analysis-set-A_10211

---

## 🛠️ Tools Used

<div>
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white"/>
<img src="https://img.shields.io/badge/Matplotlib-11557C?style=for-the-badge"/>
<img src="https://img.shields.io/badge/SQL-PostgreSQL%2FMySQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white"/>
<img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white"/>
<img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black"/>
</div>

---

## 🎯 Objective
Find where delivery delay is concentrated (service type / route / hub) and whether it's trending up, to prioritize corrective action.

**Business questions:**
1. Which service type, route, and hub account for the most delay?
2. Is monthly delay trending up, and which routes exceed 8 total delay days?

---

## 📂 Project Structure

```
data-analysis-set-A_10211/
├── README.md
├── Data/ (deliveries.csv, routes.csv, clean_data.csv)
├── sql/ (setup.sql, queries.sql, output/*.csv)
├── python/ (Delivery_Delay_Analysis.ipynb, python_summary.csv, python_chart.png)
├── excel/ (analysis.xlsx)
└── powerbi/ (dashboard.pbix)

```
## ♻️ Workflow


deliveries.csv + routes.csv
        │
        ▼
   drop_duplicates()        (13 → 12 rows)
        │
        ▼
   LEFT JOIN on route_id    (attach route_name, service_type)
        │
        ▼
   delay_days = MAX(actual − promised, 0)
   is_delayed = actual > promised
        │
        ▼
 ┌───────┬───────────┬───────┬──────────┐
 │  SQL  │  Python   │ Excel │ Power BI │
 └───────┴───────────┴───────┴──────────┘
        │
        ▼
   Reconcile total delay days across all 4 tools
        │
        ▼
   Findings → Recommendation

---


## 📂 Project Files

| File | Description |
|---|---|
| `Data/deliveries.csv` | Raw — 13 rows (1 exact duplicate: `record_id 12`) |
| `Data/routes.csv` | Route master — 4 routes |
| `Data/clean_data.csv` | Cleaned & merged — 12 rows |
| `sql/setup.sql` | Creates & seeds tables |
| `sql/queries.sql` | 5 analysis queries |
| `python/Delivery_Delay_Analysis.ipynb` | Clean → merge → metrics → chart |
| `excel/analysis.xlsx` | Raw / Lookup / Clean / Summary sheets |
| `powerbi/dashboard.pbix` | KPI dashboard |



## 🧬 Data Dictionary

| Column | Type | Meaning |
|---|---|---|
| `record_id` | int | Unique record ID |
| `month` | string | Jan / Feb / Mar |
| `route_id` | string | FK → `routes.route_id` |
| `hub` | string | Handling hub |
| `promised_days` | int | SLA transit days |
| `actual_days` | int | Actual transit days |
| `route_name` | string | *(clean only)* From `routes` |
| `service_type` | string | *(clean only)* Express / Standard |
| `delay_days` | int | *(clean only)* `MAX(actual − promised, 0)` |
| `is_delayed` | bool | *(clean only)* `actual > promised` |

---

## 🧹 Cleaning & Metrics

```python
deliveries = deliveries.drop_duplicates()                       # 13 → 12 rows
df = deliveries.merge(routes, on='route_id', how='left')
df['delay_days'] = (df['actual_days'] - df['promised_days']).clip(lower=0)
df['is_delayed'] = df['actual_days'] > df['promised_days']
```

- **delay_days** = `MAX(actual_days − promised_days, 0)`
- **Delay incidence rate** = `delayed_records / total_records × 100`

---

## 🐘 SQL — Setup & Run

```bash
psql -U <user> -d <db> -f sql/setup.sql
psql -U <user> -d <db> -f sql/queries.sql
```

```sql
-- Q1: delay by service_type
SELECT r.service_type, SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries d JOIN routes r ON d.route_id = r.route_id
GROUP BY r.service_type ORDER BY total_delay_days DESC;

-- Q2: routes with significant delay (>8)
SELECT d.route_id, r.route_name, SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries d JOIN routes r ON d.route_id = r.route_id
GROUP BY d.route_id, r.route_name
HAVING SUM(GREATEST(d.actual_days - d.promised_days, 0)) > 8;

-- Q3: top 2 hubs by delay
SELECT hub, SUM(GREATEST(actual_days - promised_days, 0)) AS total_delay_days
FROM deliveries GROUP BY hub ORDER BY total_delay_days DESC LIMIT 2;
```

---

## 🐍 Python — Setup & Run

```bash
pip install -r requirements.txt
jupyter notebook python/Delivery_Delay_Analysis.ipynb
```

- **Python:** 3.13.5 · **Packages:** `pandas`, `matplotlib`
- Outputs: `clean_data.csv`, `python_summary.csv`, `python_chart.png`

```python
service_summary = df.groupby('service_type').agg(
    total_delay_days=('delay_days', 'sum'),
    delayed_records=('is_delayed', 'sum'),
    total_records=('record_id', 'count'))
```

---

## 📊 Excel Sheet Guide

| Sheet | Purpose |
|---|---|
| `Raw` | Original 13-row data |
| `Lookup` | Route master (VLOOKUP source) |
| `Clean` | Deduped + merged data, cleaning check (13→12) |
| `Summary` | Hub totals + PivotTable (service_type × month) |

---

## ⚡ Power BI — Refresh Steps

```
Home → Transform Data → Data Source Settings
→ Change Source → point to new local CSV path
→ Close & Apply → Refresh
```

<img width="1165" height="657" alt="Powerbi Dashboard" src="https://github.com/user-attachments/assets/660ae9b5-e684-46f5-bca7-b6a6346e4fa7" />

---

## 📈 Results

| Service Type | Total Delay Days |
|---|---|
| Express | 12 |
| Standard | 21 |

| Route | Total Delay Days |
|---|---|
| R4 Rural Feeder | 16 |
| R1 Metro Link | 9 |
| R3 Highway Freight | 5 |
| R2 City Dash | 3 |

| Hub | Total Delay Days |
|---|---|
| Mumbai | 22 |
| Delhi | 6 |
| Chennai | 5 |
| Ahmedabad | 0 |

| Month | Total Delay Days |
|---|---|
| Jan | 7 |
| Feb | 9 |
| Mar | 17 |

**Findings:**
1. Standard delay (21) is ~2× Express (12).
2. Mumbai hub alone accounts for 22 of 33 total delay days.

**Recommendation:** Review Rural Feeder (R4) route and Mumbai hub operations first — they drive most of the delay, and monthly delay is rising (Jan 7 → Mar 17).

---

## 🔁 Cross-Tool Reconciliation

**Metric:** Total delay days

| Tool | Value |
|---|---|
| Python | 33 |
| SQL | 33 |
| Excel | 33 |
| Power BI | 42 |

**Note:** Power BI uses the raw 13-row source (duplicate `record_id 12` not removed). Python/SQL/Excel dedupe first → 33. No rounding issue; gap = 1 duplicate row × 9 delay days.

---

## 📌 Expected Outcomes

- One reconciled total-delay figure agreed across SQL, Python, Excel, Power BI
- Route- and hub-level breakdown pinpointing R4 (Rural Feeder) and Mumbai as top delay drivers
- Reusable cleaning/metric pipeline (`delay_days`, `is_delayed`, incidence rate)

---

## 🚀 Suggested Next Steps

- Extend data beyond 3 months to confirm the Jan→Mar delay trend
- Investigate root cause at Mumbai hub and R4 route (carrier, capacity, distance)
- Repoint Power BI source to `clean_data.csv` to match the other tools

---

## ⚙️ Installation & Setup

```bash
git clone https://github.com/priyasavaliya20-collab/data-analysis-set-A_10211.git
cd data-analysis-set-A_10211
pip install -r requirements.txt
```
---

## 🙏 Thank You
Feedback and suggestions are welcome.

⭐ Star the repo if this was useful.
