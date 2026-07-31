# Ecommerce DWH

Учебный data warehouse для ecommerce: генерация синтетических данных, загрузка в PostgreSQL и построение слоёв **raw → staging → dimensions/facts → marts**.

## Архитектура

```
CSV (data/raw)
    ↓
RAW        — сырые таблицы без жёсткой очистки
    ↓
STAGING    — очищенные и дедуплицированные сущности
    ↓
DWH        — dim_* + fact_order_items (star schema)
    ↓
MARTS      — materialized views для аналитики
```

### Слои

| Слой | Объекты |
|------|---------|
| Raw | `raw_customers`, `raw_products`, `raw_orders`, `raw_order_items`, `raw_payments`, `raw_returns` |
| Staging | `stg_*` — те же сущности после очистки |
| Dimensions | `dim_date`, `dim_customer`, `dim_product`, `dim_payment_method` |
| Facts | `fact_order_items` |
| Marts | `mart_sales_by_day`, `mart_top_products`, `mart_customer_ltv` |

### Пайплайн

1. Создание таблиц (raw / staging / dimensions / facts)
2. Генерация CSV (`customers`, `products`, `orders`, `order_items`, `payments`, `returns`)
3. Загрузка RAW
4. Загрузка STAGING
5. Загрузка dimensions
6. Загрузка facts
7. Создание/пересоздание marts

Точка входа: `src/main.py`.

## Требования

- Python 3.12+
- Docker / Docker Compose
- PostgreSQL 15 (через compose)

## Быстрый старт

### 1. Поднять PostgreSQL

```bash
docker compose up -d
```

БД слушает порт **5434** на хосте.

### 2. Настроить окружение

```bash
cp .env.example .env
```

Параметры по умолчанию совпадают с `docker-compose.yml`:

```env
DB_HOST=localhost
DB_PORT=5434
DB_NAME=ecommerce_dwh
DB_USER=ecommerce_user
DB_PASSWORD=ecommerce_pass
```

### 3. Установить зависимости

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Запустить пайплайн

```bash
python src/main.py
```

После успешного прогона в консоли будет `Pipeline completed successfully`.

## Структура проекта

```
ecommerce-dwh/
├── data/raw/           # сгенерированные CSV
├── sql/                # DDL и DML слоёв
├── src/
│   ├── main.py         # оркестрация пайплайна
│   ├── generate_data.py
│   ├── load_raw.py
│   ├── load_staging.py
│   ├── load_dimensions.py
│   ├── load_facts.py
│   ├── load_marts.py
│   ├── sql_loader.py
│   ├── db.py
│   └── config.py
├── docker-compose.yml
├── requirements.txt
└── .env.example
```

## Примеры запросов к marts

```sql
SELECT * FROM mart_sales_by_day ORDER BY full_date DESC LIMIT 10;
SELECT * FROM mart_top_products LIMIT 10;
SELECT * FROM mart_customer_ltv LIMIT 10;
```

Подключение:

```bash
psql -h localhost -p 5434 -U ecommerce_user -d ecommerce_dwh
```

## Зависимости

- `pandas` — генерация и работа с CSV
- `psycopg2-binary` — PostgreSQL
- `python-dotenv` — конфиг из `.env`
- `faker` — синтетические данные
