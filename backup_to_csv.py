import os
import csv
import snowflake.connector
from cryptography.hazmat.primitives import serialization

key = serialization.load_pem_private_key(
    os.environ["PRIVATE_KEY"].encode(),
    password=os.environ["PRIVATE_KEY_PASSPHRASE"].encode(),
)
private_key = key.private_bytes(
    serialization.Encoding.DER,
    serialization.PrivateFormat.PKCS8,
    serialization.NoEncryption(),
)

conn = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["DBT_USER"],
    private_key=private_key,
    role="TRANSFORM",
    warehouse="COMPUTE_WH",
    database="AIRBNB",
)

tables = {
    # Final models (for Power BI)
    "mart_fullmoon_reviews": "MART.MART_FULLMOON_REVIEWS",
    "dim_listings_w_hosts": "PROD.DIM_LISTINGS_W_HOSTS",
    "dim_hosts_cleansed": "PROD.DIM_HOSTS_CLEANSED_V2",
    # Raw data (to rebuild the project on DuckDB later)
    "raw_listings": "RAW.RAW_LISTINGS",
    "raw_hosts": "RAW.RAW_HOSTS",
    "raw_reviews": "RAW.RAW_REVIEWS",
    # Pipeline run history (for the data quality page)
    "audit_log": "PROD.AUDIT_LOG",
    "int_host_performance": "PROD.INT_HOST_PERFORMANCE",
}

os.makedirs("data_export", exist_ok=True)

for file_name, table in tables.items():
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT * FROM {table}")
        columns = [c[0] for c in cur.description]
        rows_written = 0
        with open(f"data_export/{file_name}.csv", "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.writer(f)
            writer.writerow(columns)
            while True:
                rows = cur.fetchmany(10000)
                if not rows:
                    break
                writer.writerows(rows)
                rows_written += len(rows)
        print(f"OK    {file_name}: {rows_written} rows")
    except Exception as e:
        print(f"ERROR {file_name}: {e}")

conn.close()
print("Done!")