-- models/marts/dim_customers.sql

with customers as (
    select *
    from {{ ref('stg_customers') }}
)

select * from customers
