USE ecommerce_sql_analytics;

-- Q6. What is the total revenue generated so far? (Delivered orders only.)
SELECT ROUND(SUM(oi.quantity * oi.selling_price),2) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered';

-- Q7. Which product category has sold the most units?
SELECT p.category, SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY units_sold DESC;

-- Q8. List the top 5 customers by total amount spent.
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.selling_price),2) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- Q9. Which sellers have generated more than INR 10,000 revenue? (HAVING)
SELECT s.seller_id, s.seller_name,
       ROUND(SUM(oi.quantity * oi.selling_price),2) AS seller_revenue
FROM sellers s
JOIN products p ON p.seller_id = s.seller_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY s.seller_id, s.seller_name
HAVING SUM(oi.quantity * oi.selling_price) > 10000
ORDER BY seller_revenue DESC;

-- Q10. What is the average order value per city?
WITH order_totals AS (
    SELECT o.order_id, o.customer_id,
           SUM(oi.quantity * oi.selling_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT c.city,
       ROUND(AVG(ot.order_value),2) AS average_order_value,
       COUNT(*) AS delivered_orders
FROM order_totals ot
JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.city
ORDER BY average_order_value DESC;

-- Q11. How many orders did each payment type handle, and what's the average payment value?
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders_handled,
       ROUND(AVG(payment_amount),2) AS average_payment_value
FROM payments
WHERE payment_status = 'success'
GROUP BY payment_type
ORDER BY orders_handled DESC;

-- Q12. How many orders are in each status?
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Q13. Which products are currently below 10 units of stock?
SELECT product_name, stock_quantity
FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity;
