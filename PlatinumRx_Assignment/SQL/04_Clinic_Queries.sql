-- Clinic Queries (answers for PlatinumRx assignment)
-- 1) Revenue from each sales channel in a given year (example: 2021)
SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE datetime >= '2021-01-01' AND datetime < '2022-01-01'
GROUP BY sales_channel
ORDER BY total_revenue DESC;

-- 2) Top 10 most valuable customers for a given year (2021)
SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE datetime >= '2021-01-01' AND datetime < '2022-01-01'
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- 3) Month-wise revenue, expense, profit, status for 2021
WITH rev AS (
    SELECT DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS revenue
    FROM clinic_sales
    WHERE datetime >= '2021-01-01' AND datetime < '2022-01-01'
    GROUP BY month
),
exp AS (
    SELECT DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS expenses
    FROM expenses
    WHERE datetime >= '2021-01-01' AND datetime < '2022-01-01'
    GROUP BY month
)
SELECT 
    COALESCE(r.month, e.month) AS month,
    COALESCE(r.revenue, 0) AS revenue,
    COALESCE(e.expenses, 0) AS expenses,
    COALESCE(r.revenue, 0) - COALESCE(e.expenses, 0) AS profit,
    CASE WHEN COALESCE(r.revenue, 0) - COALESCE(e.expenses, 0) > 0 THEN 'profitable' ELSE 'not-profitable' END AS status
FROM rev r
FULL OUTER JOIN exp e ON r.month = e.month
ORDER BY month;

-- 4) Most profitable clinic for each city for a given month (example month '2021-09')
WITH clinic_rev AS (
    SELECT cid, DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS revenue
    FROM clinic_sales
    GROUP BY cid, month
),
clinic_exp AS (
    SELECT cid, DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS expense
    FROM expenses
    GROUP BY cid, month
),
profit_per_clinic AS (
    SELECT c.cid, c.clinic_name, c.city, COALESCE(r.month, e.month) AS month,
           COALESCE(r.revenue,0) AS revenue, COALESCE(e.expense,0) AS expense,
           COALESCE(r.revenue,0) - COALESCE(e.expense,0) AS profit
    FROM clinics c
    LEFT JOIN clinic_rev r ON r.cid = c.cid
    LEFT JOIN clinic_exp e ON e.cid = c.cid AND e.month = r.month
)
SELECT month, city, cid, clinic_name, revenue, expense, profit
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY month, city ORDER BY profit DESC NULLS LAST) AS rn
    FROM profit_per_clinic
) t
WHERE rn = 1
ORDER BY month, city;

-- 5) Second least profitable clinic per state for a given month
WITH clinic_rev AS (
    SELECT cid, DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS revenue
    FROM clinic_sales
    GROUP BY cid, month
),
clinic_exp AS (
    SELECT cid, DATE_FORMAT(datetime, '%Y-%m') AS month, SUM(amount) AS expense
    FROM expenses
    GROUP BY cid, month
),
profit_per_clinic AS (
    SELECT c.cid, c.clinic_name, c.state, COALESCE(r.month, e.month) AS month,
           COALESCE(r.revenue,0) AS revenue, COALESCE(e.expense,0) AS expense,
           COALESCE(r.revenue,0) - COALESCE(e.expense,0) AS profit
    FROM clinics c
    LEFT JOIN clinic_rev r ON r.cid = c.cid
    LEFT JOIN clinic_exp e ON e.cid = c.cid AND e.month = r.month
)
SELECT month, state, cid, clinic_name, revenue, expense, profit
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY month, state ORDER BY profit ASC NULLS LAST) AS rn
    FROM profit_per_clinic
) t
WHERE rn = 2
ORDER BY month, state;
