USE ecommerce_sql_analytics;

-- Q14. Rank products by total revenue within each category.
WITH product_revenue AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT product_name, category, ROUND(revenue,2) AS revenue,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
FROM product_revenue
ORDER BY category, category_rank;

-- Q15. Find customers who spent more than the average customer spend.
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(oi.quantity * oi.selling_price) AS spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(spend,2) AS spend
FROM customer_spend
WHERE spend > (SELECT AVG(spend) FROM customer_spend)
ORDER BY spend DESC;

-- Q16. Identify repeat customers with more than 20 delivered orders.
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS delivered_order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 20;

-- Q17. Create monthly_sales_summary view.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.selling_price),2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m');

-- View usage:
SELECT * FROM monthly_sales_summary ORDER BY sales_month;

-- Q18. Create get_customer_history(customer_id) stored procedure.
DROP PROCEDURE IF EXISTS get_customer_history;
DELIMITER $$
CREATE PROCEDURE get_customer_history(IN p_customer_id INT)
BEGIN
    SELECT o.order_id, o.order_date, o.status,
           p.product_name, oi.quantity, oi.selling_price,
           ROUND(oi.quantity * oi.selling_price,2) AS line_total
    FROM orders o
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    LEFT JOIN products p ON p.product_id = oi.product_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC, o.order_id;
END$$
DELIMITER ;

-- Procedure usage:
-- CALL get_customer_history(1);

-- Q19. Calculate month-over-month revenue using LAG().
WITH monthly AS (
    SELECT sales_month, monthly_revenue
    FROM monthly_sales_summary
),
comparison AS (
    SELECT sales_month, monthly_revenue,
           LAG(monthly_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly
)
SELECT sales_month, monthly_revenue, previous_month_revenue,
       ROUND(100 * (monthly_revenue - previous_month_revenue) /
             NULLIF(previous_month_revenue,0),2) AS growth_percentage
FROM comparison
ORDER BY sales_month;

-- Q20. Find the highest-revenue seller in each seller city.
WITH seller_revenue AS (
    SELECT s.seller_id, s.seller_name, s.seller_city,
           SUM(oi.quantity * oi.selling_price) AS revenue
    FROM sellers s
    JOIN products p ON p.seller_id = s.seller_id
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY s.seller_id, s.seller_name, s.seller_city
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY seller_city ORDER BY revenue DESC
    ) AS city_rank
    FROM seller_revenue
)
SELECT seller_id, seller_name, seller_city, ROUND(revenue,2) AS revenue
FROM ranked
WHERE city_rank = 1;

-- Q21. Find customers who purchased in at least 3 different calendar months.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT DATE_FORMAT(o.order_date,'%Y-%m')) AS active_purchase_months
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT DATE_FORMAT(o.order_date,'%Y-%m')) >= 3;

-- Q22. Find products whose revenue is above their category's average product revenue.
WITH product_revenue AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY p.product_id, p.product_name, p.category
),
category_comparison AS (
    SELECT *,
           AVG(revenue) OVER (PARTITION BY category) AS category_avg_revenue
    FROM product_revenue
)
SELECT product_name, category, ROUND(revenue,2) AS revenue,
       ROUND(category_avg_revenue,2) AS category_avg_revenue
FROM category_comparison
WHERE revenue > category_avg_revenue
ORDER BY category, revenue DESC;

-- Q23. Calculate payment success rate by payment type.
SELECT payment_type,
       COUNT(*) AS total_attempts,
       SUM(payment_status = 'success') AS successful_attempts,
       ROUND(100 * SUM(payment_status = 'success') / COUNT(*),2) AS success_rate_pct
FROM payments
GROUP BY payment_type
ORDER BY success_rate_pct DESC;

-- Q24. Calculate each category's percentage contribution to total revenue.
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY p.category
)
SELECT category, ROUND(revenue,2) AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (),2) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;
