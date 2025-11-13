with sales as (
    select * from {{ ref('int_sales_orders_enriched') }}
)

select
    order_id,
    customer_id,
    order_date,
    order_amount_usd
from sales
