select
    order_id,
    customer_name,
    product_name,
    total_price
from {{ ref('mv_order_summary') }}
where total_price > 100
