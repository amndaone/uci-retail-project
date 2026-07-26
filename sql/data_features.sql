-- ===================================
-- Online Retail Analysis
-- Data Cleaning
-- ===================================

DROP TABLE IF EXISTS online_retail_features;

CREATE TABLE online_retail_features AS
SELECT
    *,
    quantity * unit_price AS revenue,
    EXTRACT(QUARTER FROM invoice_date) AS invoice_quarter,
    EXTRACT(YEAR FROM invoice_date) AS invoice_year,
    EXTRACT(MONTH FROM invoice_date) AS invoice_month,
    TRIM(TO_CHAR(invoice_date, 'Month')) AS month_name,
    EXTRACT(DOW FROM invoice_date) AS day_of_week,
    TRIM(TO_CHAR(invoice_date, 'Day')) AS day_name,
    EXTRACT(HOUR FROM invoice_date) AS invoice_hour
FROM online_retail_clean;