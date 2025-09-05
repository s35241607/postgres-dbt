{{
  config(
    materialized = 'materialized_view'
  )
}}

with orders as (
    select * from {{ ref('raw_orders') }}
),

products as (
    select * from {{ ref('raw_products') }}
),

customers as (
    select * from {{ ref('raw_customers') }}
),

order_details as (
    select
        o.id as order_id,
        c.first_name || ' ' || c.last_name as customer_name,
        p.name as product_name,
        o.quantity,
        p.price,
        (o.quantity * p.price) as total_price,
        o.order_date
    from orders o
    join customers c on o.customer_id = c.id
    join products p on o.product_id = p.id
)

select * from order_details
