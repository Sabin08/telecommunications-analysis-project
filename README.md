
# ABC Communications — analysis-project

A real-world SQL project built around the business domain of **ABC Communications**, a global media software company serving 3,000+ broadcasters and TV networks in 185+ countries.

## Business Context

Imagine Communications builds software that powers how TV channels broadcast and how TV ads are bought, scheduled, and tracked globally. Their internal data team maintains SQL reporting layers that feed Power BI dashboards for sales, finance, and customer success teams.

This project simulates that exact environment — an Oracle operational database feeding reporting views, mirroring the real-world pipeline:

```
Oracle (operational data) → SQL views → Power BI dashboards
```

## Database Schema

| Table | Rows | Description |
|---|---|---|
| `regions` | 5 | Geographic territories |
| `customers` | 200 | Broadcasters, IPTV providers, sports venues worldwide |
| `products` | 6 | Imagine's software products (Versio, Landmark, OSI-X, etc.) |
| `contracts` | 60 | Software license agreements |
| `contract_lines` | 90 | Individual product lines within contracts |
| `support_tickets` | 75 | Customer support cases |

## Files

| File | Description |
|---|---|
| `01_schema.sql` | CREATE TABLE statements with comments |
| `02_data.sql` | INSERT statements with realistic broadcast industry data |
| `03_business_queries.sql` | 5 real business problem solutions |
| `04_views.sql` | Reporting views simulating a Power BI reporting layer |

## Business Problems Solved

**Problem 1 — Contract Renewal Risk**
Identifies customers at churn risk: contracts expiring within 6 months with no active follow-up. Uses `NOT EXISTS` subquery pattern.

**Problem 2 — Support Health by Customer**
Ticket volume, unresolved count, and average resolution time per customer. Uses multi-CTE pattern with `LEFT JOIN` to preserve customers with only unresolved tickets.

**Problem 3 — Product Revenue Breakdown**
Revenue and percentage share per product. Uses nested window function `SUM(SUM()) OVER()` for percentage calculation.

**Problem 4 — Regional Performance Dashboard**
Territory summary for regional VPs. Uses `COUNT(DISTINCT)` to avoid inflation from one-to-many joins.

**Problem 5 — Customer Lifetime Value**
Ranks customers by total revenue generated using `DENSE_RANK()` window function.

## Key SQL Concepts Demonstrated

- Multi-table JOINs (INNER, LEFT, multi-level)
- Aggregate functions with GROUP BY
- Conditional aggregation with CASE WHEN
- Common Table Expressions (CTEs)
- Window functions (DENSE_RANK, SUM OVER)
- Subqueries and NOT EXISTS pattern
- Data validation queries
- Reporting views for BI layer
- Oracle-specific syntax (SYSDATE, MONTHS_BETWEEN, DATE literals, DUAL)

## Platform

- **Database:** Oracle 23ai Free (Docker)
- **Client:** DBeaver
- **Target migration:** Snowflake (ETL pipeline — in progress)

## Author

**Sabin Mainali**
SQL Developer & Data Analyst | Toronto, ON
[LinkedIn](https://www.linkedin.com/in/sabinmainali) | [GitHub](https://github.com/sabinmainali)
