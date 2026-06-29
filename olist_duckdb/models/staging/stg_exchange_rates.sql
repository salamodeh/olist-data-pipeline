select
    cast(date as date) as date,
    cast(usd_rate as decimal(10,6)) as usd_rate,
    cast(eur_rate as decimal(10,6)) as eur_rate
from {{ source('raw', 'exchange_rates') }}
where date is not null