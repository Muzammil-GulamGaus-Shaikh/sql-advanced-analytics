-- Performance Analysis
-- Analyze yearly product performance
-- Compare each product’s yearly sales with:
-- 1) its average yearly sales
-- 2) its previous year’s sales

WITH yearly_product_sales AS (
	SELECT 
		YEAR(f.order_date) AS order_year,      -- extract year from order date
		p.product_name,                        -- product name
		SUM(f.sales_amount) AS current_sales   -- total sales per product per year
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY 
		YEAR(f.order_date),
		p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,

	-- average yearly sales for each product
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

	-- difference between current sales and average sales
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_in_avg,

	-- check if current sales are above or below average
	CASE 
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
		ELSE 'Avg'
	END AS avg_change,

	-- previous year sales for the same product
	LAG(current_sales) OVER (
		PARTITION BY product_name 
		ORDER BY order_year
	) AS py_sales,

	-- compare current year sales with previous year
	CASE 
		WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
		WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
		ELSE 'No Change' 
	END AS diff_py_years

FROM yearly_product_sales
ORDER BY product_name, order_year;
