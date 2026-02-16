/*
=============================================================
Time-Based Analysis (Change Over Time)
=============================================================
Purpose:
    Analyze how key business metrics change over time.
    This section focuses on sales performance trends
    across different time granularities such as
    yearly and monthly levels.

    The analysis helps identify growth patterns,
    seasonality, and long-term business performance.
*/

-- Analyze sales performance over time (Yearly)
SELECT 
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);


-- Analyze sales performance over time (Yearly & Monthly)
SELECT 
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- Monthly trend analysis using date truncation
SELECT 
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);


-- Yearly trend analysis using date truncation
SELECT 
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) AS sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY DATETRUNC(YEAR, order_date);


-- Monthly sales trend with formatted date (for reporting)
SELECT 
	FORMAT(order_date, 'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
