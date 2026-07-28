from sql_loader import execute_sql_file

def load_dimensions() -> None:
    execute_sql_file("load_dimensions.sql")
    print("Dimensions loaded successfully")


if __name__ == "__main__":
    load_dimensions()