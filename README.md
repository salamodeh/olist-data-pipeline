# Olist E-Commerce Data Pipeline

An end-to-end, cloud-native data pipeline built entirely with free tools — ingesting Brazilian e-commerce data and enriching it with external APIs to answer business questions the raw data alone can't.

## Live dashboard

[View the interactive dashboard](https://datastudio.google.com/reporting/bdc37536-654b-44c0-80a6-ad0e2796684a)


## What it does

- Ingests Olist's Brazilian e-commerce dataset (orders, customers, products, payments)
- Enriches it with two external APIs: Frankfurter (ECB exchange rates) and Nager.Date (public holidays)
- Transforms raw data into clean, tested dbt models
- Answers questions like: *What is revenue worth in stable currency (USD/EUR)? Do sales spike around holidays?*

## Stack

| Stage | Tool |
|---|---|
| Ingestion | dlt |
| Storage | DuckDB |
| Transformation | dbt Core |
| Testing | dbt tests |
| Documentation | dbt docs |
| Version control | Git / GitHub |

## Pipeline architecture

Olist CSVs + Frankfurter API + Nager.Date API → dlt (ingestion) → DuckDB (storage) → dbt staging models (cleaning) → dbt marts (business logic: FX conversion, holiday flags) → dbt tests (data quality) → dbt docs (documentation + lineage)

## Key model: `fct_orders_enriched`

Joins orders with same-day exchange rates and holiday calendars to produce:
- Order value in BRL, USD, and EUR
- Holiday flag and holiday name per order

## Run it yourself

```bash
pip install dbt-duckdb dlt[duckdb]
python ingest_olist.py
python ingest_apis.py
cd olist_duckdb
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Author

**Salam Odeh** — Senior Data Engineer with 12 years in banking data (ETL, Snowflake migration, ML in production at Bank of Palestine). Building this project as part of a transition into the modern cloud data stack.

[LinkedIn](https://www.linkedin.com/in/salam-odeh-93068a62/) · [Portfolio](https://salamodeh.github.io)
