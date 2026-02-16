/*
===============================================================================
CUMULATIVE SALES ANALYSIS
===============================================================================

Purpose:
- Analyze sales performance over time (monthly & yearly).
- Track overall business growth using running total (cumulative sales).
- Identify revenue trends and long-term growth patterns.
- Smooth out fluctuations using moving average.
- Support data-driven decision making for revenue monitoring.
*/


-- Monthly sales with running total and moving average
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,   -- cumulative sales
	AVG(total_sales) OVER(ORDER BY order_date) AS moving_average_price   -- moving average
FROM (
	SELECT 
		DATETRUNC(MONTH, order_date) AS order_date,  -- group by month
		SUM(sales_amount) AS total_sales             -- total sales per month
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) t;


-- Yearly sales with running total and moving average
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,   -- cumulative sales
	AVG(total_sales) OVER(ORDER BY order_date) AS moving_average_price   -- moving average
FROM (
	SELECT 
		DATETRUNC(YEAR, order_date) AS order_date,   -- group by year
		SUM(sales_amount) AS total_sales             -- total sales per year
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
) t;
