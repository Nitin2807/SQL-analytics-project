with customer_spending as(
select 
    c.customer_key,
    SUM(f.sales_amount) as total_spending,
    MIN(f.order_date) as first_order_date,
    MAX(f.order_date) as last_order_date,
    DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
    on c.customer_key = f.customer_key
group by c.customer_key
)

select
    customer_segment,
    count(customer_key) as total_customers
from (
    select
        customer_key,
        case when 
            lifespan >= 12 and total_spending > 5000 then 'vip'
            when lifespan >= 12 and total_spending between 1000 and 5000 then 'loyal'
            when lifespan < 12 and total_spending > 1000 then 'new'
            else 'occasional' end as customer_segment
    from customer_spending
) as segments
group by customer_segment
order by total_customers desc;