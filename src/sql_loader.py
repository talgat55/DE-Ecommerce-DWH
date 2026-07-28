from pathlib import Path

from config import BASE_DIR
from db import get_connection

SQL_DIR = BASE_DIR / "sql"


def execute_sql_file(filename: str) -> None:
    sql_path = SQL_DIR / filename

    if not sql_path.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_path}")

    sql = sql_path.read_text(encoding="utf-8")

    connection = get_connection()
    try:
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(sql)
    finally:
        connection.close()
