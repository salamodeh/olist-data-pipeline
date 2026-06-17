select
    date,
    local_name,
    name
from {{ source('raw', 'holidays') }}