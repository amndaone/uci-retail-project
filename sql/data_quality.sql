-- ===================================
-- Online Retail Analysis
-- Data Quality Assessment
-- ===================================

-- Orders with no customer ID
-- Result: 135080
SELECT COUNT(*) AS null_customer_id
FROM online_retail
WHERE customer_id IS NULL;

-- Negative quantity of items
-- Result: 10624
SELECT COUNT(*) AS negative_quantity
FROM online_retail
WHERE quantity < 0;

-- No quantity of items
-- Result: 0
SELECT COUNT(*) AS no_quantity
FROM online_retail
WHERE quantity = 0;

-- Negative unit price
-- Results: 2
SELECT COUNT(*) AS negative_unit_price
FROM online_retail
WHERE unit_price < 0;

-- No unit price
-- Results: 2519
SELECT COUNT(*) AS no_unit_price
FROM online_retail
WHERE unit_price = 0;

-- Cancelled invoice rows
-- Result: 9288
SELECT COUNT(*) AS cancelled_orders
FROM online_retail
WHERE invoice_no LIKE 'C%';

-- Cancelled invoice orders
-- Result: 3836
-- Each invoice contains multiple products
SELECT COUNT(DISTINCT invoice_no)
FROM online_retail
WHERE invoice_no LIKE 'C%';

-- ===================================
-- Data Quality Investigation
-- ===================================

-- Investigate negative prices
-- Finding: Only 2 records have negative unit prices
-- Negative prices were used to adjust bad debt rather than reflect product sales
SELECT *
FROM online_retail
WHERE unit_price < 0;

-- Investigate no prices:
-- Finding: Many invoices with no unit prices also have no customer ID
SELECT *
FROM online_retail
WHERE unit_price = 0
LIMIT 100;

-- Items with no unit price and no customer ID
-- Finding: 2475 out of 2519 items with no unit price also have no customer ID
SELECT COUNT(*)
FROM online_retail
WHERE unit_price = 0 AND customer_id IS NULL;

-- Investigate invoices with no customer ID and country
-- Finding: 1480 invoices with no customer ID do not come from the UK
SELECT COUNT(*) AS null_customer_id
FROM online_retail
WHERE customer_id IS NULL and country != 'United Kingdom';

-- Finding: 133600 of invoices with no customer ID come from the UK
SELECT COUNT(*) AS null_customer_id
FROM online_retail
WHERE customer_id IS NULL and country = 'United Kingdom';

-- Cancelled orders and negative quantity
-- Finding: All invoices with negative quantity come from cancelled orders
SELECT COUNT(*)
FROM online_retail
WHERE invoice_no LIKE 'C%' AND quantity < 0;

-- No description and no customer ID
-- Finding: 1454 of invoices with no customer ID also have no description
SELECT COUNT(*)
FROM online_retail
WHERE description IS NULL AND customer_id IS NULL;

-- Identify duplicate rows
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    COUNT(*) AS duplicate_count
FROM online_retail
GROUP BY
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country
HAVING COUNT(*) > 1;

-- Count number of duplicate rows
-- Finding: 5268 duplicate rows present
-- These represent repeated line items that could inflate sales metrics
-- if not removed during data cleaning
SELECT SUM(duplicate_count - 1) AS duplicate_rows
FROM (
    SELECT
        COUNT(*) AS duplicate_count
    FROM online_retail
    GROUP BY
        invoice_no,
        stock_code,
        description,
        quantity,
        invoice_date,
        unit_price,
        customer_id,
        country
    HAVING COUNT(*) > 1
) AS duplicates;

-- Identify whether non-priced items are from select products
-- Finding: Appears to be spread out between various products

SELECT
    stock_code,
    description,
    COUNT(*) AS occurrences
FROM online_retail
WHERE unit_price = 0
GROUP BY stock_code, description
ORDER BY occurrences DESC
LIMIT 100;
