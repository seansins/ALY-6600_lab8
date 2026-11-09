-- ALY 6600 Lab 8: CTE queries
-- Weixiang (Sean) Cai

-- Task 1. Customers whose total spending is above the average customer total.
WITH customer_spend AS (
  SELECT
    p.customer_id,
    SUM(p.amount) AS total_spend
  FROM `sakila-aly6600.sakila.payment` AS p
  GROUP BY p.customer_id
)
SELECT
  customer_id,
  total_spend
FROM customer_spend
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_spend)
ORDER BY total_spend DESC;


-- Task 2. Top five cities by number of above-average-spending customers,
-- with the total revenue from those customers.
WITH customer_spend AS (
  SELECT
    p.customer_id,
    SUM(p.amount) AS total_spend
  FROM `sakila-aly6600.sakila.payment` AS p
  GROUP BY p.customer_id
),
overall_avg AS (
  SELECT AVG(total_spend) AS avg_spend
  FROM customer_spend
),
above_average AS (
  SELECT
    cs.customer_id,
    cs.total_spend
  FROM customer_spend AS cs
  CROSS JOIN overall_avg AS oa
  WHERE cs.total_spend > oa.avg_spend
),
above_average_city AS (
  SELECT
    aa.customer_id,
    aa.total_spend,
    ci.city_id,
    ci.city
  FROM above_average AS aa
  INNER JOIN `sakila-aly6600.sakila.customer` AS c
    ON aa.customer_id = c.customer_id
  INNER JOIN `sakila-aly6600.sakila.address` AS a
    ON c.address_id = a.address_id
  INNER JOIN `sakila-aly6600.sakila.city` AS ci
    ON a.city_id = ci.city_id
)
SELECT
  city,
  COUNT(*)         AS above_avg_customers,
  SUM(total_spend) AS total_revenue
FROM above_average_city
GROUP BY city_id, city
ORDER BY above_avg_customers DESC, total_revenue DESC, city
LIMIT 5;
