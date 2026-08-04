create view gold.report_customers as 
with base_query as (
select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as full_name,
DateDiff(year, c.birthdate, GETDATE()) as age
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
where order_date is not null)

,customer_agg as (
select 
    customer_key,
    customer_number,
    full_name,
    age,
    count(distinct order_number) as total_orders,
    sum(sales_amount) as total_sales,
    sum(quantity) as total_quantity,
    count(distinct product_key) as total_products,
    max(order_date) as last_order_date,
    DateDiff(day, max(order_date), GETDATE()) as lifespan
from base_query 
group by 
customer_key,
customer_number,
full_name,
age)

SELECT
customer_key,
customer_number,
full_name,
age,
case 
    when age < 25 then 'Genz'
    when age between 25 and 40 then 'Millennial'
    when age between 41 and 56 then 'GenX'
    when age between 57 and 75 then 'Boomer'
    else 'Silent' end as age_group, 
case 
    when lifespan >= 12 and total_sales > 5000 then 'vip'
    when lifespan >= 12 and total_sales between 1000 and 5000 then 'loyal'
    when lifespan < 12 and total_sales > 1000 then 'new'
    else 'occasional' end as customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
datediff(month, last_order_date, getdate()) as recency,
lifespan,
case when total_sales = 0 then 0
    else total_sales / total_orders end as avg_order_value,
case when lifespan =0 then 0
    else total_orders / lifespan end as order_frequency
from customer_agg

