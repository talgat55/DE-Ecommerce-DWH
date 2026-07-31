from generate_data import generate_all
from load_raw import load_all_raw
from load_staging import load_staging
from load_dimensions import load_dimensions
from load_facts import load_facts
from load_marts import load_marts
from sql_loader  import execute_sql_file

def create_tables() -> None:
    execute_sql_file("create_raw_tables.sql")
    execute_sql_file("create_staging_tables.sql")
    execute_sql_file("create_dimensions.sql")
    execute_sql_file("create_facts.sql")

def run_pipeline() -> None:
    print("1. Create tables...")
    create_tables()

    print("2. Generating source data...")
    generate_all()

    print("3. Loading RAW layer...")
    load_all_raw()

    print("4. Loading STAGING layer...")
    load_staging()

    print("5. Loading dimensions...")
    load_dimensions()

    print("6. Loading facts...")
    load_facts()

    print("7. Creating marts...")
    load_marts()

    print("Pipeline completed successfully")

if __name__ == "__main__":
    run_pipeline()
