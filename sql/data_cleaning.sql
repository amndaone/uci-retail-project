-- ===================================
-- Online Retail Analysis
-- Data Cleaning
-- ===================================

DROP TABLE IF EXISTS online_retail_clean;

CREATE TABLE online_retail_clean AS
SELECT DISTINCT *
FROM online_retail
WHERE invoice_no NOT LIKE 'C%'
    AND quantity > 0
    AND unit_price >= 0;