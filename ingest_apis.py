import dlt
import requests

def load_apis():
    pipeline = dlt.pipeline(
        pipeline_name="olist",
        destination="duckdb",
        dataset_name="raw"
    )

# Exchange rates: BRL to USD and EUR, for 2017-2018 (Olist date range)
    try:
        fx_response = requests.get(
            "https://api.frankfurter.app/2017-01-01..2018-12-31",
            params={"from": "BRL", "to": "USD,EUR"},
            timeout=10
        )
        fx_response.raise_for_status()
        fx_data = fx_response.json()
    except requests.exceptions.RequestException as e:
        print(f"Failed to fetch exchange rates: {e}")
        raise

    fx_rows = []
    for date, rates in fx_data["rates"].items():
        fx_rows.append({
            "date": date,
            "usd_rate": rates.get("USD"),
            "eur_rate": rates.get("EUR")
        })

# Public holidays in Brazil for 2017 and 2018
    holiday_rows = []
    for year in [2017, 2018]:
        try:
            resp = requests.get(
                f"https://date.nager.at/api/v3/PublicHolidays/{year}/BR",
                timeout=10
            )
            resp.raise_for_status()
        except requests.exceptions.RequestException as e:
            print(f"Failed to fetch holidays for {year}: {e}")
            raise
        for h in resp.json():
            holiday_rows.append({
                "date": h["date"],
                "local_name": h["localName"],
                "name": h["name"]
            })

    pipeline.run(
        dlt.resource(fx_rows, name="exchange_rates", write_disposition="replace")
    )
    pipeline.run(
        dlt.resource(holiday_rows, name="holidays", write_disposition="replace")
    )

    print(f"Loaded {len(fx_rows)} exchange rate rows")
    print(f"Loaded {len(holiday_rows)} holiday rows")

if __name__ == "__main__":
    load_apis()