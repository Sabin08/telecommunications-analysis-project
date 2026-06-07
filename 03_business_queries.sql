-- ============================================================
-- Imagine Communications — SQL Practice Project
-- File: 03_business_queries.sql
-- Description: 5 real-world business problem solutions
-- Author: Sabin Mainali
-- Platform: Oracle 23ai Free
-- ============================================================


-- ============================================================
-- PROBLEM 1: Contract Renewal Risk Report
-- Business Need: Identify customers whose contracts expire within
-- 6 months with no active or renewed follow-up contract.
-- Used by: Sales Director to prioritize renewal outreach.
-- ============================================================

CREATE OR REPLACE VIEW vw_churn_risk AS
SELECT
    c.company_name,
    r.region_name,
    c2.total_value,
    CEIL(c2.end_date - SYSDATE) AS remaining_days
FROM customers c
JOIN contracts c2 ON c.customer_id = c2.customer_id
JOIN regions r ON c.region_id = r.region_id
WHERE c2.status = 'Active'
AND MONTHS_BETWEEN(c2.end_date, SYSDATE) <= 6
AND MONTHS_BETWEEN(c2.end_date, SYSDATE) > 0
AND NOT EXISTS (
    -- Exclude customers who already have another active/renewed contract
    SELECT 1 FROM contracts c3
    WHERE c3.customer_id = c.customer_id
    AND c3.status IN ('Active', 'Renewed')
    AND c3.contract_id != c2.contract_id
)
ORDER BY remaining_days;

-- Query the view
SELECT * FROM vw_churn_risk;


-- ============================================================
-- PROBLEM 2: Support Health by Customer
-- Business Need: Identify struggling customers by analyzing
-- ticket volume, unresolved count, and resolution time.
-- Used by: Customer Success Team
-- ============================================================

WITH company_details AS (
    SELECT
        c.company_name,
        COUNT(st.ticket_id) AS total_ticket_raised,
        COUNT(CASE WHEN st.status IN ('Open', 'In Progress') THEN 1 END) AS unresolved_tickets_count
    FROM customers c
    JOIN support_tickets st ON c.customer_id = st.customer_id
    GROUP BY c.company_name
),
avg_res AS (
    SELECT
        c.company_name,
        ROUND(AVG(st.resolved_date - st.created_date), 2) AS average_resolution_days
    FROM customers c
    JOIN support_tickets st ON c.customer_id = st.customer_id
    WHERE st.resolved_date IS NOT NULL  -- Only resolved tickets have a resolution time
    GROUP BY c.company_name
)
SELECT
    cd.company_name,
    cd.total_ticket_raised,
    cd.unresolved_tickets_count,
    ar.average_resolution_days
FROM company_details cd
LEFT JOIN avg_res ar ON cd.company_name = ar.company_name  -- LEFT JOIN to keep customers with only unresolved tickets
ORDER BY cd.total_ticket_raised DESC;


-- ============================================================
-- PROBLEM 3: Product Revenue Breakdown
-- Business Need: Understand which products drive the most revenue
-- and their share of total revenue.
-- Used by: Finance & Product Management
-- ============================================================

SELECT
    p.product_name,
    p.category,
    COUNT(DISTINCT cl.contract_id) AS total_contracts,
    SUM(cl.line_total) AS total_revenue,
    -- Window function: percentage share of each product vs grand total
    ROUND((SUM(cl.line_total) / SUM(SUM(cl.line_total)) OVER()) * 100, 2) AS percent_share
FROM contract_lines cl
JOIN products p ON cl.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- PROBLEM 4: Regional Performance Dashboard
-- Business Need: Give regional VPs a summary of their territory.
-- Used by: Regional Vice Presidents
-- ============================================================

SELECT
    r.region_name,
    COUNT(DISTINCT cu.customer_id) AS total_customers,       -- DISTINCT avoids double counting customers with multiple contracts
    SUM(CASE WHEN co.status = 'Active' THEN 1 END) AS total_active_contracts,
    SUM(co.total_value) AS total_contract_value,
    ROUND(AVG(co.total_value), 2) AS average_contract_value
FROM customers cu
LEFT JOIN contracts co ON cu.customer_id = co.customer_id   -- LEFT JOIN to include customers without contracts
JOIN regions r ON cu.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_contract_value DESC;


-- ============================================================
-- PROBLEM 5: Customer Lifetime Value
-- Business Need: Rank customers by total revenue generated
-- across all contracts over time.
-- Used by: Executive Team
-- ============================================================

WITH lifetime_value AS (
    SELECT
        cu.company_name,
        cu.country,
        COUNT(co.contract_id) AS total_contracts,
        SUM(COALESCE(co.total_value, 0)) AS total_contract_value,   -- COALESCE handles NULL values from cancelled contracts
        ROUND(AVG(COALESCE(co.total_value, 0)), 2) AS average_contract_value
    FROM customers cu
    JOIN contracts co ON cu.customer_id = co.customer_id            -- INNER JOIN: only revenue-generating customers
    GROUP BY cu.company_name, cu.country
)
SELECT
    lv.*,
    DENSE_RANK() OVER (ORDER BY lv.total_contract_value DESC) AS company_rank  -- DENSE_RANK avoids gaps in ranking on ties
FROM lifetime_value lv
ORDER BY company_rank;
