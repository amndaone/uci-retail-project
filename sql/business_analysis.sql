-- ===================================
-- Business Analysis
-- ===================================

-- Total revenue of completed sales (entire dataset)
-- Result:  10,642,110.80
SELECT SUM(revenue)
FROM online_retail_features;

-- Total revenue of completed sales (2010)
-- Result:  821,452.73
SELECT SUM(revenue)
FROM online_retail_features
WHERE invoice_year = 2010;

-- Total revenue of completed sales (2011)
-- Result: 9,820,658.07
SELECT SUM(revenue)
FROM online_retail_features
WHERE invoice_year = 2011;

-- Total number of completed orders
-- Result: 20726
SELECT COUNT(DISTINCT invoice_no) AS completed_orders
FROM online_retail_clean;

-- Average order value
-- Result: 513.47
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT
        invoice_no,
        SUM(revenue) AS order_total
    FROM online_retail_features
    GROUP BY invoice_no
) AS orders;

-- Number of unique customers
-- Result: 4339
SELECT COUNT(DISTINCT customer_id)
FROM online_retail_features;

-- Average revenue per customer (with customer ID)
-- Result: 2048.22
SELECT ROUND(AVG(sum_revenue), 2) AS avg_rev_customer
FROM (
    SELECT
        customer_id,
        SUM(revenue) AS sum_revenue
    FROM online_retail_features
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_revenue;

-- ===================================
-- Sales Performance
-- ===================================

-- Monthly revenue over time
SELECT invoice_year, invoice_month, month_name, SUM(revenue) AS monthly_revenue
FROM online_retail_features
GROUP BY invoice_year, invoice_month, month_name
ORDER BY invoice_year, invoice_month;

-- Rank top-selling months based on monthly revenue
-- Finding: November 2011 generated most revenue, February 2011 least revenue
SELECT invoice_year, invoice_month, month_name, SUM(revenue),
RANK() OVER (ORDER BY SUM(revenue) DESC)
FROM online_retail_features
GROUP BY invoice_year, invoice_month, month_name;

-- Rank months based on order volume
-- Finding: November 2011 highest no. of orders
-- December 2011 least (note: dataset last day is Dec. 9 2011)
SELECT
    invoice_year,
    invoice_month,
    month_name,
    COUNT(DISTINCT invoice_no) AS total_monthly_orders,
    RANK() OVER (ORDER BY COUNT(DISTINCT invoice_no) DESC) AS order_volume_rank
FROM online_retail_features
GROUP BY invoice_year, invoice_month, month_name;

-- ===================================
-- Product Analysis
-- ===================================

-- Rank top 10 products by most units sold
SELECT
    stock_code,
    description,
    SUM(quantity) AS total_units_sold,
    RANK() OVER (ORDER BY SUM(quantity) DESC) AS product_rank
FROM online_retail_features
GROUP BY stock_code, description
LIMIT 10;

-- Rank top 10 products by revenue
SELECT
    stock_code,
    description,
    SUM(revenue) AS product_revenue,
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM online_retail_features
GROUP BY stock_code, description
LIMIT 10;

-- Identify how many orders for each product
SELECT stock_code, description, COUNT(DISTINCT invoice_no) AS orders_with_product
FROM online_retail_features
GROUP BY stock_code, description
ORDER BY orders_with_product DESC;

-- Average quantity of items per order
SELECT AVG(sum_quantity) AS avg_quantity_per_order
FROM(
    SELECT
        invoice_no,
        SUM(quantity) AS sum_quantity
    FROM online_retail_features
    GROUP BY invoice_no
) AS total_quantity;

-- ===================================
-- Customer Analysis
-- ===================================

-- Average customer spend (with customer ID)
SELECT ROUND(AVG(sum_revenue), 2) AS avg_customer_spend
FROM(
    SELECT
        customer_id,
        SUM(revenue) AS sum_revenue
    FROM online_retail_features
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_revenue;

-- How many repeat customers
SELECT COUNT(*) AS repeat_customers
FROM(
    SELECT customer_id
    FROM online_retail_features
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(DISTINCT invoice_no) > 1
) AS repeat_customer_list;

-- How many orders top 10 customers placed
SELECT customer_id, COUNT(DISTINCT invoice_no) AS order_count
FROM online_retail_features
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 10;

-- Rank top 10 customers by revenue
SELECT
    customer_id,
    SUM(revenue),
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS customer_rank
FROM online_retail_features
WHERE customer_id IS NOT NULL
GROUP BY customer_id
LIMIT 10;

-- Average number of orders per customer
SELECT ROUND(AVG(order_count), 2) AS avg_order_per_customer
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS order_count
    FROM online_retail_features
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS orders_per_customer;

-- ===================================
-- Geographical Analysis
-- ===================================

-- Top 10 countries by number of orders
SELECT country, COUNT(DISTINCT invoice_no) AS order_per_country
FROM online_retail_features
GROUP BY country
ORDER BY order_per_country DESC
LIMIT 10;

-- Top 10 countries by revenue
SELECT country, SUM(revenue) AS revenue_per_country
FROM online_retail_features
GROUP BY country
ORDER BY revenue_per_country DESC
LIMIT 10;

-- Which countries have the most customers (with customer ID)
-- NOTE: This query is only valid for invoices with idenified customer IDs
-- United Kingdom is missing a significant number of customer IDs, so customer count is likely underestimated
SELECT country, COUNT(DISTINCT customer_id) AS customers_per_country
FROM online_retail_features
WHERE customer_id IS NOT NULL
GROUP BY country
ORDER BY customers_per_country DESC
LIMIT 15;

-- Countries with highest average order value
SELECT country, ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM (
    SELECT country, invoice_no, SUM(revenue) AS order_revenue
    FROM online_retail_features
    GROUP BY country, invoice_no
) AS country_orders
GROUP BY country
ORDER BY avg_order_value DESC
LIMIT 10;

-- ===================================
-- Time Analysis
-- ===================================

-- Identify which day has highest number of orders
-- Finding: Thursday has most orders; No Saturday orders
SELECT day_of_week, day_name, COUNT(DISTINCT invoice_no) AS orders_per_day
FROM online_retail_features
GROUP BY day_of_week, day_name
ORDER BY orders_per_day DESC;

-- Identify which day of week generates the most revenue
-- Result: Thursday
SELECT day_of_week, day_name, SUM(revenue) AS revenue_per_day
FROM online_retail_features
GROUP BY day_of_week, day_name
ORDER BY revenue_per_day DESC;

-- Which hour of the day has the highest number of orders
-- Result: 12 PM
SELECT invoice_hour, COUNT(DISTINCT invoice_no) AS hourly_order
FROM online_retail_features
GROUP BY invoice_hour
ORDER BY hourly_order DESC;

-- Which hour of the day generates most revenue
-- Result: 10 AM
SELECT invoice_hour, SUM(revenue) AS hourly_revenue
FROM online_retail_features
GROUP BY invoice_hour
ORDER BY hourly_revenue DESC;

-- Identify number of orders for each quarter (2011)
-- Result: 4, 3, 2, 1
SELECT invoice_quarter, COUNT(DISTINCT invoice_no) AS quarterly_orders
FROM online_retail_features
WHERE invoice_year = 2011
GROUP BY invoice_quarter
ORDER BY quarterly_orders DESC;

-- Identify the revenue for each quarter (2011)
-- Result: 4, 3, 2, 1
SELECT invoice_quarter, SUM(revenue) AS quarterly_revenue
FROM online_retail_features
WHERE invoice_year = 2011
GROUP BY invoice_quarter
ORDER BY quarterly_revenue DESC;