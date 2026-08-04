with product_segments as (
select 
product_key,
product_name,
cost,
case when cost<100 then 'Low'
     when cost between 100 and 500 then 'Medium'
     else 'High' end as cost_range
from gold.dim_products)

select 
cost_range,
count(product_key) as product_count
from product_segments
group by cost_range
order by product_count desc;