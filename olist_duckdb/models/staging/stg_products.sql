select
    product_id,
    product_category_name,
    cast(product_weight_g as decimal(10,2)) as product_weight_g,
    cast(product_length_cm as decimal(10,2)) as product_length_cm,
    cast(product_height_cm as decimal(10,2)) as product_height_cm,
    cast(product_width_cm as decimal(10,2)) as product_width_cm
from {{ source('raw', 'olist_products_dataset') }}
where product_id is not null