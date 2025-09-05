-- models/staging/stg_customers.sql

select
    customer_id,
    first_name,
    last_name
from raw.customers
