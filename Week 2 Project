## Week 2 Update — FinTrust Digital Bank Analytics

Moved from Week 1 planning into full execution this week. Summary of what's 
in this repo as of Week 2:

**Data Quality**
- `FinTrust_Week2_Data_Quality_Workbook.xlsx` — formula-driven QA on both 
  source datasets (1,500 customers / 12,000 transactions). 0 duplicates, 
  0 broken joins, 96 missing Device_Type + 96 missing Location values 
  identified and recoded to "Unknown" rather than dropped.

**SQL Analysis**
- `FinTrust_Week2_SQL_Analysis.sql` — 8 business questions covering customer 
  behavior, transaction value, channel performance, and risk-review patterns. 
  Written in portable ANSI SQL (tested in DuckDB, runs unchanged in 
  PostgreSQL/MySQL/SQL Server).

**Python EDA**
- `FinTrust_Week2_Data_Analysis.ipynb` — 9 executed visualizations exploring 
  transaction amounts, types, channels, status, and risk patterns. Includes 
  a code-generated findings summary (pulled live from the analysis, not 
  hardcoded) so results self-correct if the underlying data changes.

**Dashboard**
- Power BI build spec included in `/docs` — full DAX measure set + 3-page 
  layout (Executive Overview / Customer & Segment Analysis / Channel & Risk 
  Analysis), pending build in Power BI Desktop.

Key finding this week: transaction-value averages are nearly flat across 
FinTrust's four customer segments (₦45.6K–₦49.1K) — the "Premium" label 
isn't currently reflected in materially larger transactions.

Next: implement the Power BI dashboard, tighten the risk-review feature set 
for cross-track alignment with the Data Science model.

#AnalystLabAfrica
