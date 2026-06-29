-- This test fails if any row is returned.
-- It checks that delivery never happens before the purchase date.

select
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
from {{ ref('fct_order_items') }}
where order_delivered_customer_date < order_purchase_timestamp