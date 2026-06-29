select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    cast(payment_value as decimal(10,2)) as payment_value
from {{ source('raw', 'olist_order_payments_dataset') }}
where order_id is not null