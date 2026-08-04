with yearly_product_sales as (
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p 
on f.product_key = p.product_key
where order_date is not null
group by 
year(f.order_date),
p.product_name)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) as avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as sales_diff,
case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Average' 
     when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Average' 
     else 'At Average' end as performance_category,
lag(current_sales) over (partition by product_name order by order_year) as previous_year_sales,
current_sales - lag(current_sales) over (partition by product_name order by order_year) as sales_change_from_previous_year
from yearly_product_sales
order by product_name, order_year 