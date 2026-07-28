TRUNCATE TABLE
    stg_returns,
    stg_payments,
    stg_order_items,
    stg_orders,
    stg_products,
    stg_customers;

INSERT INTO stg_customers (
    customer_id,
    first_name,
    last_name,
    email,
    country,
    city,
    registered_at
)
SELECT DISTINCT ON (customer_id)
    customer_id,
    INITCAP(TRIM(first_name)),
    INITCAP(TRIM(last_name)),
    LOWER(TRIM(email)),
    NULLIF(TRIM(country), ''),
    NULLIF(TRIM(city), ''),
    registered_at
FROM  raw_customers
WHERE customer_id IS NOT NULL
    AND first_name IS NOT NULL
    AND last_name IS NOT NULL
    AND email IS NOT NULL
    AND registered_at IS NOT NULL
ORDER BY customer_id, loaded_at DESC;

INSERT INTO stg_products (
        product_id,
        product_name,
        category,
        price,
        created_at
)
SELECT DISTINCT ON (product_id)
    product_id,
    INITCAP(TRIM(product_name)),
    INITCAP(TRIM(category)),
    price,
    created_at
FROM raw_products
WHERE product_id IS NOT NULL
    AND product_name  IS NOT NULL
    AND category  IS NOT NULL
    AND price > 0
    AND created_at IS NOT NULL
ORDER BY product_id, loaded_at DESC;

INSERT INTO stg_orders (
        order_id,
        customer_id,
        order_status,
        order_created_at
)
SELECT DISTINCT ON (order_id)
    order_id,
    customer_id,
    LOWER(TRIM(order_status)),
    order_created_at
FROM raw_orders
WHERE order_id IS NOT NULL
    AND order_id  IS NOT NULL
    AND order_status  IS NOT NULL
    AND order_created_at  IS NOT NULL
    AND LOWER(TRIM(order_status)) IN (
        'created',
        'paid',
        'shipped',
        'delivered',
        'cancelled'
    )
ORDER BY order_id, loaded_at DESC;

INSERT INTO stg_order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    line_total
)
SELECT DISTINCT ON (order_item_id)
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    ROUND(quantity * unit_price, 2)
FROM raw_order_items
WHERE order_item_id IS NOT NULL
    AND order_id  IS NOT NULL
    AND product_id  IS NOT NULL
    AND quantity > 0
    AND unit_price > 0
ORDER BY order_item_id, loaded_at DESC;

INSERT INTO stg_payments (
    payment_id,
    order_id,
    payment_method,
    payment_status,
    amount,
    paid_at
)
SELECT DISTINCT ON (payment_id)
    payment_id,
    order_id,
    LOWER(TRIM(payment_method)),
    LOWER(TRIM(payment_status)),
    amount,
    paid_at
FROM raw_payments
WHERE payment_id IS NOT NULL
  AND order_id IS NOT NULL
  AND payment_method IS NOT NULL
  AND payment_status IS NOT NULL
  AND amount >= 0
  AND LOWER(TRIM(payment_method)) IN (
      'card',
      'paypal',
      'bank_transfer',
      'cash'
  )
  AND LOWER(TRIM(payment_status)) IN (
      'success',
      'failed',
      'refunded'
  )
ORDER BY payment_id, loaded_at DESC;

INSERT INTO stg_returns (
    return_id,
    order_id,
    return_reason,
    return_status,
    returned_at
)
SELECT DISTINCT ON (return_id)
    return_id,
    order_id,
    LOWER(TRIM(return_reasons)),
    LOWER(TRIM(return_status)),
    return_at
FROM raw_returns
WHERE return_id IS NOT NULL
  AND order_id IS NOT NULL
  AND return_reasons IS NOT NULL
  AND return_status IS NOT NULL
  AND return_at IS NOT NULL
  AND LOWER(TRIM(return_status)) IN (
      'requested',
      'approved',
      'rejected',
      'completed'
  )
ORDER BY return_id, loaded_at DESC;