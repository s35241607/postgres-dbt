with base as (
    select * from {{ ref('stg_sales_orders') }}
),

order_usd as (
    select
        *,
        case when order_currency = 'USD' then order_amount
             when order_currency = 'TWD' then order_amount / 30.0
             else null end as order_amount_usd
    from base
)

select * from order_usd
