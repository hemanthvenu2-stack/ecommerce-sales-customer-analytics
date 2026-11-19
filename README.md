# E-Commerce Sales & Customer Analytics (MySQL)

A beginner-to-advanced SQL portfolio project based on the supplied SQL Portfolio Project Guide. The project simulates an online store and answers practical business questions about customers, orders, products, sellers, revenue, and payments.

## Project objective
Design a relational MySQL database, insert sample e-commerce data, and answer 20+ business questions using SQL. The project demonstrates database design, data manipulation, joins, aggregation, subqueries, CTEs, window functions, views, and stored procedures.

## Tools
- MySQL 8.0+
- MySQL Workbench

This is a SQL-only project. No Python, Power BI, Excel, JavaScript, or web frameworks are required.

## Dataset
The project uses custom-built synthetic data. Order dates are generated relative to `CURDATE()` so the "last 30 days" business question remains useful whenever the seed script is run.

## Database tables
1. `customers` — customer name, city, signup date.
2. `sellers` — seller details and location.
3. `products` — product, category, seller, price and stock.
4. `orders` — customer, order date and status.
5. `order_items` — products, quantities and order-time selling prices.
6. `payments` — payment type, amount and status.

## Repository structure
```text
ecommerce-sql-analytics/
├── README.md
├── schema/
│   └── create_tables.sql
├── data/
│   └── sample_data.sql
├── queries/
│   ├── 01_beginner_questions.sql
│   ├── 02_intermediate_questions.sql
│   └── 03_advanced_questions.sql
└── screenshots/
    └── Add MySQL Workbench result screenshots here
```

## Setup
1. Install MySQL Server 8.0+ and MySQL Workbench.
2. Open MySQL Workbench and connect to your local server.
3. Run `schema/create_tables.sql`.
4. Run `data/sample_data.sql`.
5. Run the three query files in numerical order.
6. Run the view and stored procedure statements included in the advanced query file.

Run scripts only once on a fresh database unless you intentionally reset it. The schema script drops and recreates the project database.

## Business questions
### Beginner
- Customers from a selected city
- Orders placed in the last 30 days
- Ten most expensive products
- Delivered orders
- Customers who signed up in 2025

### Intermediate
- Total revenue generated
- Category with the most units sold
- Top five customers by total spend
- Sellers above a revenue threshold
- Average order value per city
- Order count and average payment by payment type

### Advanced
- Rank products by revenue within category
- Customers spending above average
- Repeat customers with more than 20 orders
- Monthly sales summary view
- Customer order history stored procedure
- Plus additional analysis questions in the SQL files

## Metric definitions
- **Revenue:** Sum of `quantity * selling_price` for delivered orders. This project treats delivered orders as recognized sales.
- **Units sold:** Sum of item quantities for delivered orders.
- **Average order value:** Delivered order revenue divided by delivered order count.
- **Customer spend:** Total delivered order-item revenue for a customer.
- **Seller revenue:** Delivered order-item revenue attributed to the seller of each product.
- **Payment analysis:** Uses payment records and payment status independently from order-item revenue.

Important: payments and order items are separate fact tables. Aggregate them separately before joining, otherwise multiple payment rows can multiply order-item revenue.

## Screenshots to add
Capture:
- Successful database and table creation
- `SHOW TABLES` output
- One beginner query result
- One intermediate query result
- One advanced window-function result
- `monthly_sales_summary` view output
- Stored procedure output

## What I learned
Update this section after completing the project. Mention how you used joins, grouping, HAVING, subqueries, CTEs, window functions, views, and stored procedures to answer business questions.

## Author
Add your name, GitHub profile, and LinkedIn profile before publishing.
