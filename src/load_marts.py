from sql_loader import execute_sql_file

def load_marts() -> None:
    execute_sql_file("create_marts.sql")
    print("Marts created successfully")

if __name__ == "__main__":
    load_marts()