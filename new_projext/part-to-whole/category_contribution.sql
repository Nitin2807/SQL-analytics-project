with category_sales as (
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by category)

select 
category,
total_sales,
SUM(total_sales) over () as overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) over ()) * 100, 2),'%') as contribution_percentage
from category_sales 