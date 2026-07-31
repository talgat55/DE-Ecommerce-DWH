from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = "/opt/airflow/project"

default_args = {
    "owner": "talgat",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

with DAG(
    dag_id="ecommerce_dwh_pipeline",
    description="E-commerce DWH pipeline: RAW -> STAGING -> DIM -> FACT -> MARTS",
    default_args=default_args,
    start_date=datetime(2026,7,1),
    schedule=None,
    catchup=False,
    tags=["dwh", "ecommerce", "postgres"]
) as dag:

    create_raw_tables = BashOperator(
        task_id="create_raw_tables",
        bash_command=(
            f"cd {PROJECT_DIR} &&"
            "python -c \"from sql_loader import execute_sql_file; "
            "execute_sql_file('create_raw_tables.sql')\""
        ),
    )

    create_staging_tables = BashOperator(
        task_id="create_staging_tables",
        bash_command=(
            f"cd {PROJECT_DIR} &&"
            "python -c \"from sql_loader import execute_sql_file; "
            "execute_sql_file('create_staging_tables.sql')\""
        ),
    )

    create_dimensions = BashOperator(
        task_id="create_dimensions",
        bash_command=(
            f"cd {PROJECT_DIR} &&"
            "python -c \"from sql_loader import execute_sql_file; "
            "execute_sql_file('create_dimensions.sql')\""
        ),
    )

    create_facts = BashOperator(
        task_id="create_facts",
        bash_command=(
            f"cd {PROJECT_DIR} &&"
            "python -c \"from sql_loader import execute_sql_file; "
            "execute_sql_file('create_facts.sql')\""
        ),
    )

    generate_data = BashOperator(
        task_id="generate_data",
        bash_command=(
            f"cd {PROJECT_DIR} && python src/generate_data.py"
        ),
    )

    load_raw = BashOperator(
        task_id="load_raw",
        bash_command=(
            f"cd {PROJECT_DIR} && python src/load_raw.py"
        ),
    )

    load_staging = BashOperator(
        task_id="load_staging",
        bash_command=(
            f"cd {PROJECT_DIR} && python src/load_staging.py"
        ),
    )

    load_dimensions = BashOperator(
        task_id="load_dimensions",
        bash_command=(
            f"cd {PROJECT_DIR} && python src/load_dimensions.py"
        ),
    )

    load_facts = BashOperator(
        task_id="load_facts",
        bash_command=f"cd {PROJECT_DIR} && python src/load_facts.py",
    )

    load_marts = BashOperator(
        task_id="load_marts",
        bash_command=f"cd {PROJECT_DIR} && python src/load_marts.py",
    )

    (
        create_raw_tables
        >> create_staging_tables
        >> create_dimensions
        >> create_facts
        >> generate_data
        >> load_raw
        >> load_staging
        >> load_dimensions
        >> load_facts
        >> load_marts
    )