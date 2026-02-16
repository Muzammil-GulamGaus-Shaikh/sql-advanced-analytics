-- Segment products into cost ranges
-- Count how many products fall into each cost segment

WITH product_segment AS(
SELECT 
	product_key,
	product_name,
	cost,
	CASE 
		WHEN cost < 100 THEN 'Below 100'        -- low cost products
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'  
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'ABOVE 1000'                       -- high cost products
	END cost_range
FROM gold.dim_products)

SELECT 
	cost_range,
	COUNT(product_key) total_products   -- number of products in each range
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;


-- Segment customers based on spending behavior
-- Classification based on life span and total sales

WITH customer_spending AS(
SELECT
	c.customer_key,
	SUM(f.sales_amount) total_sales,          -- total spending per customer
	MIN(order_date) first_order,              -- first purchase date
	MAX(order_date) last_order,               -- last purchase date
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) life_span  -- customer active months
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT 
	customer_segment,
	COUNT(customer_key) total_customers  -- number of customers per segment
FROM(
SELECT 
	customer_key,
	CASE 
		WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'       -- long-term high value
		WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'  -- long-term low value
		ELSE 'New'                                                   -- short-term customers
	END customer_segment
FROM customer_spending)t
GROUP BY customer_segment
ORDER BY total_customers DESC;
