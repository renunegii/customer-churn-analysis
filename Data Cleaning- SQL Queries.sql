SET SQL_SAFE_UPDATES = 0;
-- Should show 6418
SELECT COUNT(*) FROM customer_data;

-- See first 3 rows
SELECT * FROM customer_data LIMIT 3;

-- Checking for Empty values
SELECT COUNT(*) AS real_nulls 
FROM customer_data 
WHERE Value_Deal = '';

-- 