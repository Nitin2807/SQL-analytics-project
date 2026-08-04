SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (
        partition by order_date
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date, -- or DATETRUNC(month, order_date) in SQL Server 2022+
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) AS subquery
ORDER BY order_date;