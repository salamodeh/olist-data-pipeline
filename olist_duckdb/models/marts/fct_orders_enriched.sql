
{{ config(materialized='table') }}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select
        order_id,
        sum(price) as total_price,
        sum(freight_value) as total_freight
    from {{ ref('stg_order_items') }}
    group by order_id
),

fx as (
    select * from {{ ref('stg_exchange_rates') }}
),

holidays as (
    select * from {{ ref('stg_holidays') }}
)

select
    o.order_id,
    o.customer_id,
    o.order_status,
    cast(o.order_purchase_timestamp as date) as order_date,
    oi.total_price,
    oi.total_freight,
    oi.total_price + oi.total_freight as order_total_brl,
    fx.usd_rate,
    fx.eur_rate,
    round((oi.total_price + oi.total_freight) / nullif(fx.usd_rate, 0), 2) as order_total_usd,
    round((oi.total_price + oi.total_freight) / nullif(fx.eur_rate, 0), 2) as order_total_eur,
    case when h.date is not null then true else false end as is_holiday,
    h.local_name as holiday_name
from orders o
left join order_items oi on o.order_id = oi.order_id
left join fx on cast(o.order_purchase_timestamp as date) = fx.date
left join holidays h on cast(o.order_purchase_timestamp as date) = h.date