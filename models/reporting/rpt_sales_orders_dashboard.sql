with fct as (
    select * from {{ ref('fct_sales_orders') }}
),
dim as (
    select * from {{ ref('dim_customers') }}
)

select
    fct.order_id,
    fct.order_date,
    fct.order_amount_usd,
    dim.customer_name
from fct
left join dim on fct.customer_id = dim.customer_id
