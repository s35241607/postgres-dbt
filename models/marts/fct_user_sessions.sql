{{
    config(
        materialized='incremental',
        unique_key='session_id',
        incremental_strategy='merge'
    )
}}

with source as (

    select * from {{ ref('raw_orders') }}

),

renamed as (

    select
        id as order_id,
        customer_id,
        order_date

    from source

),

-- A more complex transformation
session_data as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} as session_id,
        customer_id,
        order_date,
        min(order_date) over (partition by customer_id) as first_order_date,
        max(order_date) over (partition by customer_id) as most_recent_order_date,
        count(order_id) over (partition by customer_id, order_date) as orders_in_session,
        -- In a real world scenario, you might have a session timestamp
        current_timestamp as dbt_updated_at
    from renamed
)

select * from session_data

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where order_date > (select max(order_date) from {{ this }})

{% endif %}
