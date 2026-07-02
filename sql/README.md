# SQL Queries — IRA Compliance Dashboard

This folder contains the SQL used to prepare data for the 
IRA Apprenticeship Compliance Dashboard. Queries are written 
for Snowflake syntax but the logic is portable across most 
modern SQL platforms.

## 01_extract_timecard_data.sql

Pulls worked hours for IRA-classified employees across active 
projects. Uses window functions to identify current primary job 
assignments and filters to compliance-relevant pay codes and 
cost centers.

**Techniques demonstrated:**
- Common Table Expressions (CTEs) for modular logic
- Window functions with QUALIFY (Snowflake-specific)
- Multi-table joins with proper aliasing
- Business-driven WHERE logic
- Defensive coding (DISTINCT, IS NOT NULL checks)

## Note on Data

All schema names, table names, and identifiers are illustrative 
and representative of industry patterns. This query demonstrates 
SQL technique and business logic rather than reflecting any 
specific organization's production data.
