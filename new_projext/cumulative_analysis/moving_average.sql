SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_sales,
    AVG(avg_price) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_avg_price
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date, -- or DATETRUNC(month, order_date) in SQL Server 2022+
        SUM(sales_amount) AS total_sales,
        avg(price) as avg_price 
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) AS subquery
ORDER BY order_date;