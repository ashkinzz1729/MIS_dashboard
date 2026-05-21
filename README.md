# Construction Project MIS Dashboard

## Business Problem
A large EPC contractor managing multiple infrastructure projects (hospitals, highways,
industrial plants) needs a centralized MIS to track project health, milestone delays,
team costs, and schedule performance across its entire portfolio.
This project answers 10 key project controls questions using SQL.

## Dataset Overview

| Table | Description | Rows |
|-------|-------------|------|
| `clients` | Project owners — Govt, PSU, Private | 6 |
| `departments` | Internal departments (Civil, MEP, QA, HSE) | 6 |
| `projects` | Active project portfolio with contract values | 8 |
| `milestones` | Key deliverables with planned vs actual dates | 22 |
| `project_team` | Site team with designations and monthly costs | 20 |
| `progress_updates` | Monthly planned vs actual % progress | 20 |

## Real Projects Referenced
- AIIMS Guwahati and AIIMS Bibinagar (hospital construction)
- NH-44 Nagpur–Gondia Expressway (highway)
- NMDC Steel Plant Utilities (industrial)
- Adani Mundra Port Warehouses (industrial)
- ORR Elevated Corridor Hyderabad (highway)
- RVNL Railway Station Redevelopment (railway)

## SQL Concepts Used
- `DISTINCT ON` — fetching latest record per project
- `CASE WHEN` — health status, delay classification, SPI bands
- `LAG()` — month-over-month progress gain per project
- `RANK() OVER` — cost ranking across projects
- `NULLIF` — safe SPI division
- `CTE (WITH ... AS)` — delay pattern identification
- Multi-table JOINs across 4 tables
- `INTERVAL` — deadline proximity filter
- Date arithmetic — delay days calculation

## Key Business Questions Answered
1. Overall project dashboard — planned vs actual with health status
2. Milestone delay analysis — days delayed per milestone
3. Schedule Performance Index (SPI) per project
4. Progress trend over time using LAG (monthly gain)
5. Team headcount and monthly manpower cost per project
6. Client-wise portfolio — contract value and project status
7. Department-wise milestone completion rate
8. Projects nearing deadline in next 6 months
9. CTE — projects with consistent delay pattern (3+ months behind)
10. Project manager workload and portfolio value

## Sample Query and Output

**Q3 — Schedule Performance Index:**
```sql
SELECT project_name, planned_progress, actual_progress,
    ROUND(actual_progress / NULLIF(planned_progress, 0), 3) AS spi,
    CASE
        WHEN actual_progress / NULLIF(planned_progress, 0) >= 1.0 THEN 'On Schedule'
        WHEN actual_progress / NULLIF(planned_progress, 0) >= 0.90 THEN 'Slight Delay'
        ELSE 'Behind Schedule'
    END AS schedule_status
FROM projects p JOIN latest_progress lp ON p.project_id = lp.project_id;
```

**Output:**
| project_name | planned_pct | actual_pct | spi | schedule_status |
|---|---|---|---|---|
| ORR Elevated Corridor | 85.00 | 68.00 | 0.800 | Behind Schedule |
| NH-44 Four Laning | 95.00 | 83.00 | 0.874 | Behind Schedule |
| AIIMS Guwahati | 92.00 | 82.00 | 0.891 | Slight Delay |
| AIIMS Bibinagar | 75.00 | 72.00 | 0.960 | Slight Delay |

## How to Run
1. Create database: `CREATE DATABASE construction_mis_db;`
2. Run `schema.sql` — creates all tables and inserts data
3. Run `queries.sql` — executes all 10 analysis queries

## Tools
- PostgreSQL 14+
- pgAdmin 4 / DBeaver

## Author
Giridhar Namballa | Civil Engineer → Data Analyst
[LinkedIn](https://linkedin.com/in/giridharnamballa-a9333a7a) | [GitHub](https://github.com/ashkinzz1729)
