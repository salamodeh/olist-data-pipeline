with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

payments as (
    select
        order_id,
        min(payment_type) as payment_type,
        min(payment_installments) as payment_installments,
        sum(payment_value) as order_payment_total
    from {{ ref('stg_order_payments') }}
    group by order_id
),

categories as (
    select * from {{ ref('stg_product_category_translation') }}
),

fx as (
    select * from {{ ref('stg_exchange_rates') }}
),

holidays as (
    select * from {{ ref('stg_holidays') }}
)

select
   {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }} as item_id,
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    o.order_status,
    cast(o.order_purchase_timestamp as date) as order_date,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city,
    c.customer_state,
    s.seller_city,
    s.seller_state,
    coalesce(cat.product_category_name_english, p.product_category_name, 'unknown') as category_name_english,
    p.product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    p.product_length_cm * p.product_height_cm * p.product_width_cm as product_volume_cm3,
    py.payment_type,
    py.payment_installments,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value as item_total_brl,
    round((oi.price + oi.freight_value) / nullif(fx.usd_rate, 0), 2) as item_total_usd,
    round((oi.price + oi.freight_value) / nullif(fx.eur_rate, 0), 2) as item_total_eur,
    case when h.date is not null then true else false end as is_holiday,
    h.local_name as holiday_name,
    datediff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) as delivery_days
from order_items oi
left join orders o on oi.order_id = o.order_id
left join customers c on o.customer_id = c.customer_id
left join products p on oi.product_id = p.product_id
left join sellers s on oi.seller_id = s.seller_id
left join categories cat on p.product_category_name = cat.product_category_name
left join payments py on oi.order_id = py.order_id
left join fx on cast(o.order_purchase_timestamp as date) = fx.date
left join holidays h on cast(o.order_purchase_timestamp as date) = h.date
