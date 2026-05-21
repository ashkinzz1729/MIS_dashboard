-- ============================================================
-- PROJECT 1: Construction Project MIS Dashboard
-- Queries File — 10 Business Questions
-- Tool: PostgreSQL 14+
-- ============================================================


-- Q1: Overall project status dashboard — planned vs actual progress with variance
SELECT
    p.project_name,
    p.project_type,
    p.location,
    p.contract_value_cr,
    p.current_status,
    p.project_manager,
    pu.update_date                          AS last_update,
    pu.planned_progress                     AS planned_pct,
    pu.actual_progress                      AS actual_pct,
    ROUND(pu.actual_progress - pu.planned_progress, 2) AS variance_pct,
    CASE
        WHEN pu.actual_progress >= pu.planned_progress  THEN 'On Track'
        WHEN pu.planned_progress - pu.actual_progress <= 5 THEN 'Slight Delay'
        ELSE 'Critical Delay'
    END                                     AS health_status
FROM projects p
JOIN (
    SELECT DISTINCT ON (project_id)
        project_id, update_date, planned_progress, actual_progress
    FROM progress_updates
    ORDER BY project_id, update_date DESC
) pu ON p.project_id = pu.project_id
ORDER BY variance_pct ASC;


-- Q2: Milestone delay analysis — how many days delayed per project?
SELECT
    p.project_name,
    m.milestone_name,
    m.planned_date,
    m.actual_date,
    m.status,
    CASE
        WHEN m.actual_date IS NOT NULL
            THEN m.actual_date - m.planned_date
        WHEN m.status = 'Delayed'
            THEN CURRENT_DATE - m.planned_date
        ELSE NULL
    END                                     AS delay_days
FROM milestones m
JOIN projects p ON m.project_id = p.project_id
WHERE m.status IN ('Delayed', 'Completed')
ORDER BY delay_days DESC NULLS LAST;


-- Q3: Project-wise schedule performance index (SPI = actual % / planned %)
--     SPI < 1 = behind schedule, SPI = 1 = on track, SPI > 1 = ahead
WITH latest_progress AS (
    SELECT DISTINCT ON (project_id)
        project_id, planned_progress, actual_progress
    FROM progress_updates
    ORDER BY project_id, update_date DESC
)
SELECT
    p.project_name,
    p.current_status,
    p.contract_value_cr,
    lp.planned_progress,
    lp.actual_progress,
    ROUND(lp.actual_progress / NULLIF(lp.planned_progress, 0), 3) AS spi,
    CASE
        WHEN lp.actual_progress / NULLIF(lp.planned_progress, 0) >= 1.0 THEN 'Ahead / On Schedule'
        WHEN lp.actual_progress / NULLIF(lp.planned_progress, 0) >= 0.90 THEN 'Slight Delay'
        ELSE 'Behind Schedule'
    END                                     AS schedule_status
FROM projects p
JOIN latest_progress lp ON p.project_id = lp.project_id
ORDER BY spi ASC;


-- Q4: Progress trend per project over time using LAG (month-over-month gain)
SELECT
    p.project_name,
    pu.update_date,
    pu.actual_progress,
    LAG(pu.actual_progress) OVER (
        PARTITION BY pu.project_id ORDER BY pu.update_date
    )                                       AS prev_actual_progress,
    ROUND(
        pu.actual_progress - LAG(pu.actual_progress) OVER (
            PARTITION BY pu.project_id ORDER BY pu.update_date
        ), 2
    )                                       AS progress_gained_this_period
FROM progress_updates pu
JOIN projects p ON pu.project_id = p.project_id
ORDER BY p.project_name, pu.update_date;


-- Q5: Total team headcount and monthly manpower cost per project
SELECT
    p.project_name,
    p.current_status,
    COUNT(pt.team_id)                       AS team_size,
    SUM(pt.monthly_cost_k)                  AS monthly_cost_k,
    ROUND(AVG(pt.monthly_cost_k), 2)        AS avg_cost_per_person_k,
    RANK() OVER (ORDER BY SUM(pt.monthly_cost_k) DESC) AS cost_rank
FROM project_team pt
JOIN projects p ON pt.project_id = p.project_id
GROUP BY p.project_name, p.current_status
ORDER BY monthly_cost_k DESC;


-- Q6: Client-wise portfolio — total contract value, number of projects, active count
SELECT
    c.client_name,
    c.client_type,
    COUNT(p.project_id)                     AS total_projects,
    SUM(CASE WHEN p.current_status = 'Active'    THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN p.current_status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN p.current_status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed,
    SUM(p.contract_value_cr)                AS total_contract_value_cr
FROM clients c
JOIN projects p ON c.client_id = p.client_id
GROUP BY c.client_name, c.client_type
ORDER BY total_contract_value_cr DESC;


-- Q7: Department-wise milestone completion rate
SELECT
    d.dept_name,
    COUNT(m.milestone_id)                   AS total_milestones,
    SUM(CASE WHEN m.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN m.status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed,
    SUM(CASE WHEN m.status = 'Pending'   THEN 1 ELSE 0 END) AS pending,
    ROUND(
        100.0 * SUM(CASE WHEN m.status = 'Completed' THEN 1 ELSE 0 END)
        / COUNT(m.milestone_id), 2
    )                                       AS completion_rate_pct
FROM milestones m
JOIN departments d ON m.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY completion_rate_pct DESC;


-- Q8: Projects nearing deadline in next 6 months with current progress
SELECT
    p.project_name,
    p.project_type,
    p.location,
    p.planned_end,
    p.planned_end - CURRENT_DATE            AS days_remaining,
    lp.actual_progress                      AS current_progress_pct,
    (100 - lp.actual_progress)              AS work_remaining_pct,
    p.project_manager
FROM projects p
JOIN (
    SELECT DISTINCT ON (project_id)
        project_id, actual_progress
    FROM progress_updates
    ORDER BY project_id, update_date DESC
) lp ON p.project_id = lp.project_id
WHERE p.planned_end BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '180 days'
  AND p.current_status != 'Completed'
ORDER BY days_remaining ASC;


-- Q9: CTE — identify projects with consistent delay pattern (delayed 3+ updates)
WITH delay_flags AS (
    SELECT
        project_id,
        update_date,
        planned_progress,
        actual_progress,
        CASE
            WHEN actual_progress < planned_progress THEN 1
            ELSE 0
        END AS is_delayed
    FROM progress_updates
),
delay_count AS (
    SELECT
        project_id,
        COUNT(*)                            AS total_updates,
        SUM(is_delayed)                     AS delayed_updates
    FROM delay_flags
    GROUP BY project_id
)
SELECT
    p.project_name,
    p.current_status,
    p.contract_value_cr,
    dc.total_updates,
    dc.delayed_updates,
    ROUND(100.0 * dc.delayed_updates / dc.total_updates, 2) AS delay_frequency_pct
FROM delay_count dc
JOIN projects p ON dc.project_id = p.project_id
WHERE dc.delayed_updates >= 2
ORDER BY delay_frequency_pct DESC;


-- Q10: Project manager workload — how many active projects and total contract value
SELECT
    p.project_manager,
    COUNT(p.project_id)                     AS total_projects,
    SUM(CASE WHEN p.current_status = 'Active'  THEN 1 ELSE 0 END) AS active_projects,
    SUM(CASE WHEN p.current_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_projects,
    SUM(p.contract_value_cr)                AS total_value_cr,
    ROUND(AVG(p.contract_value_cr), 2)      AS avg_project_value_cr
FROM projects p
GROUP BY p.project_manager
ORDER BY total_value_cr DESC;
