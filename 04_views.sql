-- ============================================================
-- Imagine Communications — SQL Practice Project
-- File: 04_views.sql
-- Description: Reporting views that simulate the Snowflake
-- reporting layer feeding Power BI dashboards
-- Author: Sabin Mainali
-- Platform: Oracle 23ai Free
-- ============================================================


-- ============================================================
-- VIEW 1: Churn Risk
-- Customers with contracts expiring in 6 months, no renewal
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
    SELECT 1 FROM contracts c3
    WHERE c3.customer_id = c.customer_id
    AND c3.status IN ('Active', 'Renewed')
    AND c3.contract_id != c2.contract_id
);


-- ============================================================
-- VIEW 2: Customer Contract Summary
-- Full customer overview with contract and support metrics
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    cu.customer_id,
    cu.company_name,
    cu.country,
    r.region_name,
    cu.customer_type,
    COUNT(DISTINCT co.contract_id)                                    AS total_contracts,
    COUNT(DISTINCT CASE WHEN co.status = 'Active' THEN co.contract_id END) AS active_contracts,
    SUM(COALESCE(co.total_value, 0))                                  AS lifetime_value,
    COUNT(DISTINCT st.ticket_id)                                      AS total_tickets,
    COUNT(DISTINCT CASE WHEN st.status IN ('Open','In Progress') THEN st.ticket_id END) AS open_tickets
FROM customers cu
LEFT JOIN contracts co ON cu.customer_id = co.customer_id
LEFT JOIN support_tickets st ON cu.customer_id = st.customer_id
JOIN regions r ON cu.region_id = r.region_id
GROUP BY
    cu.customer_id,
    cu.company_name,
    cu.country,
    r.region_name,
    cu.customer_type;


-- ============================================================
-- VIEW 3: Product Revenue Summary
-- Revenue breakdown by product for finance reporting
-- ============================================================

CREATE OR REPLACE VIEW vw_product_revenue AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.annual_price,
    COUNT(DISTINCT cl.contract_id)                                          AS total_contracts,
    SUM(cl.line_total)                                                      AS total_revenue,
    ROUND((SUM(cl.line_total) / SUM(SUM(cl.line_total)) OVER()) * 100, 2)  AS revenue_percent_share
FROM products p
LEFT JOIN contract_lines cl ON p.product_id = cl.product_id
GROUP BY p.product_id, p.product_name, p.category, p.annual_price;


-- ============================================================
-- VIEW 4: Regional Performance
-- Territory summary for regional VP dashboards
-- ============================================================

CREATE OR REPLACE VIEW vw_regional_performance AS
SELECT
    r.region_id,
    r.region_name,
    COUNT(DISTINCT cu.customer_id)                                          AS total_customers,
    COUNT(DISTINCT CASE WHEN co.status = 'Active' THEN co.contract_id END) AS active_contracts,
    SUM(COALESCE(co.total_value, 0))                                        AS total_contract_value,
    ROUND(AVG(co.total_value), 2)                                           AS avg_contract_value
FROM regions r
LEFT JOIN customers cu ON r.region_id = cu.region_id
LEFT JOIN contracts co ON cu.customer_id = co.customer_id
GROUP BY r.region_id, r.region_name;
