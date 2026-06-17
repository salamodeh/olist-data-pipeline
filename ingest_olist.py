import dlt
import pandas as pd
from pathlib import Path

DATA_DIR = Path("data")

def load_olist():
    pipeline = dlt.pipeline(
        pipeline_name="olist",
        destination="duckdb",
        dataset_name="raw"
    )

    tables = [
        "olist_customers_dataset",
        "olist_orders_dataset",
        "olist_order_items_dataset",
        "olist_order_payments_dataset",
        "olist_order_reviews_dataset",
        "olist_products_dataset",
        "olist_sellers_dataset",
        "product_category_name_translation",
    ]

    resources = []
    for table in tables:
        df = pd.read_csv(DATA_DIR / f"{table}.csv")
        resources.append(
            dlt.resource(
                df.to_dict(orient="records"),
                name=table,
                write_disposition="replace"
            )
        )

    load_info = pipeline.run(resources)
    print(load_info)

if __name__ == "__main__":
    load_olist()