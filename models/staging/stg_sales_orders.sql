with source as (
    select * from {{ ref('raw_sales_orders') }}
)

select
    order_id::integer as order_id,
    customer_id::integer as customer_id,
    cast(order_date as date) as order_date,
    amount::numeric as order_amount,
    currency as order_currency
from source
