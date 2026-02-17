/*
=============================================================
View Name: gold.report_customer
=============================================================
Purpose:
    This view creates a comprehensive customer-level analytical report
    by combining sales and customer dimension data.

Business Objectives:
1. Collect essential customer details such as name, age, and transaction data.
2. Segment customers based on:
   - Age groups
   - Customer value (VIP, Regular, New)
3. Aggregate key customer metrics:
   - Total orders
   - Total sales
   - Total quantity purchased
   - Total distinct products purchased
   - Customer lifespan (in months)
4. Calculate important KPIs for customer analytics:
   - Recency (months since last order)
   - Average Order Value (AOV)
   - Average Monthly Spend

Notes:
- Designed for customer segmentation, retention analysis, and KPI reporting.
- Suitable for dashboards and advanced analytics use cases.
=============================================================
*/

--CREATE VIEW gold.report_customer AS

WITH base_query AS (
    /*
    ---------------------------------------------------------
    1. Base Query
    ---------------------------------------------------------
    - Retrieves core transactional and customer attributes
    - Joins fact_sales with dim_customers
    - Calculates customer age dynamically
    - Filters out records with missing order dates
    ---------------------------------------------------------
    */
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
),

customer_aggrigation AS (
    /*
    ---------------------------------------------------------
    2. Customer Aggregation
    ---------------------------------------------------------
    - Aggregates transactional data at customer level
    - Calculates total orders, sales, quantity, and products
    - Identifies customer lifespan using first and last order
    - Captures the most recent purchase date
    ---------------------------------------------------------
    */
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT 
    /*
    ---------------------------------------------------------
    3. Final Customer Report
    ---------------------------------------------------------
    - Applies age-based segmentation
    - Categorizes customers into VIP, Regular, and New
    - Computes recency and customer value KPIs
    - Produces analytics-ready customer dataset
    ---------------------------------------------------------
    */
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age group segmentation
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    -- Customer value segmentation
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    -- Recency: months since last order
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- Average Order Value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE (total_sales / total_orders)
    END AS avg_order_value,

    -- Average Monthly Spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE (total_sales / lifespan)
    END AS avg_monthly_spend

FROM customer_aggrigation;
