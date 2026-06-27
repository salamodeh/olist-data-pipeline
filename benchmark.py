import duckdb
import time

con = duckdb.connect('olist.duckdb')

query = """
SELECT order_status, is_holiday, COUNT(*) as order_count, 
       SUM(order_total_usd) as total_usd, AVG(order_total_usd) as avg_usd
FROM raw.fct_orders_enriched
GROUP BY order_status, is_holiday
"""

print("--- Benchmarking current model (view) ---")
times = []
for i in range(5):
    start = time.perf_counter()
    result = con.execute(query).fetchdf()
    elapsed = time.perf_counter() - start
    times.append(elapsed)
    print(f"Run {i+1}: {elapsed:.4f}s")

print(f"\nAverage: {sum(times)/len(times):.4f}s")
print(f"Rows returned: {len(result)}")