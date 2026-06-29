select
    cast(date as date) as date,
    local_name,
    name
from {{ source('raw', 'holidays') }}
where date is not null