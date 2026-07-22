-- ===================================
-- Online Retail Analysis
-- Data Exploration
-- ===================================

-- Total number of records
SELECT COUNT(*) AS total_rows
FROM online_retail;

-- Number of unique customers
SELECT COUNT(DISTINCT customer_id) AS no_of_customers
FROM online_retail;

-- Determine data type of each column
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'online_retail';

-- Date period
SELECT
    MIN(invoice_date) AS first_order,
    MAX(invoice_date) AS last_order
FROM online_retail;

-- Number of orders
SELECT COUNT(DISTINCT invoice_no) AS no_of_orders
FROM online_retail;

-- Number of products
SELECT COUNT(DISTINCT stock_code) AS no_of_products
FROM online_retail;

-- List of countries included
SELECT DISTINCT country
FROM online_retail;

-- Number of countries included
SELECT COUNT(DISTINCT country) AS no_of_countries
FROM online_retail;