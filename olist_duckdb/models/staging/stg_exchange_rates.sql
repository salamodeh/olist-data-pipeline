select
    date,
    usd_rate,
    eur_rate
from {{ source('raw', 'exchange_rates') }}