-- Hotel Queries (answers for PlatinumRx assignment)
-- 1) For every user, get user_id and last booked room_no
SELECT 
    u.user_id,
    b.room_no
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b2.user_id = u.user_id
);

-- 2) booking_id & total billing amount for bookings created in Nov 2021
SELECT 
    b.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON bc.booking_id = b.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE b.booking_date >= '2021-11-01' AND b.booking_date < '2021-12-01'
GROUP BY b.booking_id;

-- 3) bill_id and bill amount for bills raised in Oct 2021 having bill amount > 1000
SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01' AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;

-- 4) Most ordered and least ordered item of each month of 2021
WITH monthly_orders AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE bc.bill_date >= '2021-01-01' AND bc.bill_date < '2022-01-01'
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT 
        month,
        item_id,
        total_qty,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
    FROM monthly_orders
)
SELECT 
    month,
    item_id,
    total_qty,
    CASE 
        WHEN most_rank = 1 THEN 'MOST ORDERED'
        WHEN least_rank = 1 THEN 'LEAST ORDERED'
    END AS status
FROM ranked
WHERE most_rank = 1 OR least_rank = 1
ORDER BY month, status;

-- 5) Customers with the second highest bill value of each month of 2021
WITH monthly_customer_totals AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        b.user_id,
        SUM(bc.item_quantity * i.item_rate) AS customer_total
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    JOIN bookings b ON bc.booking_id = b.booking_id
    WHERE bc.bill_date >= '2021-01-01' AND bc.bill_date < '2022-01-01'
    GROUP BY month, b.user_id
),
ranked AS (
    SELECT
        month,
        user_id,
        customer_total,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY customer_total DESC) AS rnk
    FROM monthly_customer_totals
)
SELECT month, user_id, customer_total
FROM ranked
WHERE rnk = 2
ORDER BY month;
