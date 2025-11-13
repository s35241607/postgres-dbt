with customers as (
    select distinct customer_id from {{ ref('stg_sales_orders') }}
)

select
    customer_id,
    'Customer_' || customer_id as customer_name
from customers
