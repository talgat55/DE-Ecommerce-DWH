from sql_loader import execute_sql_file

def load_staging() -> None:
    execute_sql_file("load_staging.sql")
    print("Staging layer loaded successfully")


if __name__ == "__main__":
    load_staging()