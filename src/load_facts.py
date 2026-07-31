from sql_loader import execute_sql_file

def load_facts() -> None:
    execute_sql_file("load_facts.sql")
    print("Facts loaded successfully")

if __name__ == "__main__":
    load_facts()