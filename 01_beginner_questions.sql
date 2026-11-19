USE ecommerce_sql_analytics;

-- Q1. List all customers from a specific city.
SELECT *
FROM customers
WHERE city = 'Kochi';

-- Q2. Show all orders placed in the last 30 days.
SELECT *
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY order_date DESC;

-- Q3. Find the 10 most expensive products.
SELECT product_id, product_name, category, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Q4. List all orders with status = 'delivered'.
SELECT *
FROM orders
WHERE status = 'delivered';

-- Q5. Find customers who signed up in 2025.
SELECT customer_id, customer_name, city, signup_date
FROM customers
WHERE signup_date >= '2025-01-01'
  AND signup_date < '2026-01-01'
ORDER BY signup_date;
