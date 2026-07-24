from pathlib import Path
import pandas as pd
from psycopg2.extras import execute_values

from config import RAW_DATA_DIR
from db import get_connection

FILE_TO_TABLE = {
    "customers.csv": "raw_customers",
    "products.csv": "raw_products",
    "orders.csv": "raw_orders",
    "order_items.csv": "raw_order_items",
    "payments.csv": "raw_payments",
    "returns.csv": "raw_returns",
}

def load_csv_to_table(csv_path: Path, table_name: str) -> int:
    dataframe = pd.read_csv(csv_path)

    if dataframe.empty:
        print(f"{csv_path.name}: file is empty")
        return 0

    columns = list(dataframe.columns)
    rows = [
        tuple(None if pd.isna(value) else value for value in row)
        for row in dataframe.itertuples(index=False, name=None)
    ]

    column_names = ", ".join(columns)

    sql = f"""
        INSERT INTO {table_name} ({column_names})
        VALUES %s
    """

    connection = get_connection()

    try:
        with connection:
            with connection.cursor() as cursor:
                execute_values(cursor, sql, rows)

        print(f"{csv_path.name} -> {table_name}: loaded {len(rows)} rows")
        return len(rows)

    finally:
        connection.close()

def load_all_raw() -> int:
    total_loaded = 0

    for filename, table_name in FILE_TO_TABLE.items():
        csv_path = RAW_DATA_DIR / filename

        if not csv_path.exists():
            raise FileNotFoundError(f"File not fount: {csv_path}")

        loaded = load_csv_to_table(csv_path, table_name)
        total_loaded +=loaded

    print(f"Total loaded rows: {total_loaded}")
    return total_loaded

if __name__ == "__main__":
    load_all_raw()