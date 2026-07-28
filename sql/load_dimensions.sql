-- ============================================================
-- 1. LOAD DIM_DATE
-- ============================================================

WITH all_dates AS (
    SELECT registered_at::DATE AS event_date
    FROM stg_customers
    WHERE registered_at IS NOT NULL

    UNION ALL

    SELECT created_at::DATE AS event_date
    FROM stg_products
    WHERE created_at IS NOT NULL

    UNION ALL

    SELECT order_created_at::DATE AS event_date
    FROM stg_orders
    WHERE order_created_at IS NOT NULL

    UNION ALL

    SELECT paid_at::DATE AS event_date
    FROM stg_payments
    WHERE paid_at IS NOT NULL

    UNION ALL

    SELECT returned_at::DATE AS event_date
    FROM stg_returns
    WHERE returned_at IS NOT NULL
),
date_bounds AS (
    SELECT
        COALESCE(MIN(event_date), CURRENT_DATE) AS min_date,
        COALESCE(MAX(event_date), CURRENT_DATE) AS max_date
    FROM all_dates
),
generated_dates AS (
    SELECT
        generate_series(
            min_date,
            max_date,
            INTERVAL '1 day'
        )::DATE AS full_date
    FROM date_bounds
)
INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    TO_CHAR(full_date, 'YYYYMMDD')::INTEGER AS date_key,
    full_date,

    EXTRACT(YEAR FROM full_date)::INTEGER AS year,
    EXTRACT(QUARTER FROM full_date)::INTEGER AS quarter,
    EXTRACT(MONTH FROM full_date)::INTEGER AS month,

    TRIM(TO_CHAR(full_date, 'Month')) AS month_name,

    EXTRACT(WEEK FROM full_date)::INTEGER AS week_of_year,
    EXTRACT(DAY FROM full_date)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM full_date)::INTEGER AS day_of_week,

    TRIM(TO_CHAR(full_date, 'Day')) AS day_name,

    EXTRACT(ISODOW FROM full_date) IN (6, 7) AS is_weekend
FROM generated_dates
ON CONFLICT (date_key) DO NOTHING;


-- ============================================================
-- 2. LOAD DIM_CUSTOMER
-- SCD TYPE 2
-- ============================================================

-- Закрываем текущую версию клиента,
-- если его данные изменились в staging-слое.

UPDATE dim_customer AS target
SET
    valid_to = NOW(),
    is_current = FALSE
FROM stg_customers AS source
WHERE target.customer_id = source.customer_id
  AND target.is_current = TRUE
  AND ROW(
      target.first_name,
      target.last_name,
      target.email,
      target.country,
      target.city,
      target.registered_at
  ) IS DISTINCT FROM ROW(
      source.first_name,
      source.last_name,
      source.email,
      source.country,
      source.city,
      source.registered_at
  );


-- Добавляем:
-- 1. новых клиентов;
-- 2. новую версию изменившихся клиентов.

INSERT INTO dim_customer (
    customer_id,
    first_name,
    last_name,
    email,
    country,
    city,
    registered_at,
    valid_from,
    valid_to,
    is_current
)
SELECT
    source.customer_id,
    source.first_name,
    source.last_name,
    source.email,
    source.country,
    source.city,
    source.registered_at,
    NOW() AS valid_from,
    NULL AS valid_to,
    TRUE AS is_current
FROM stg_customers AS source
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_customer AS target
    WHERE target.customer_id = source.customer_id
      AND target.is_current = TRUE
);


-- ============================================================
-- 3. LOAD DIM_PRODUCT
-- SCD TYPE 1
-- ============================================================

INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    price,
    source_created_at
)
SELECT
    product_id,
    product_name,
    category,
    price,
    created_at
FROM stg_products
ON CONFLICT (product_id)
DO UPDATE SET
    product_name = EXCLUDED.product_name,
    category = EXCLUDED.category,
    price = EXCLUDED.price,
    source_created_at = EXCLUDED.source_created_at,
    dwh_updated_at = NOW();


-- ============================================================
-- 4. LOAD DIM_PAYMENT_METHOD
-- ============================================================

INSERT INTO dim_payment_method (
    payment_method
)
SELECT DISTINCT
    payment_method
FROM stg_payments
WHERE payment_method IS NOT NULL
ON CONFLICT (payment_method) DO NOTHING;