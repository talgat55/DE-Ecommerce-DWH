CREATE TABLE IF NOT EXISTS raw_customers (
    customer_id BIGINT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    country TEXT,
    city TEXT,
    registered_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_products (
    product_id BIGINT,
    product_name TEXT,
    category TEXT,
    price NUMERIC(12, 1),
    created_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_orders (
    order_id BIGINT,
    customer_id BIGINT,
    order_status TEXT,
    order_created_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_order_items (
    order_item_id BIGINT,
    order_id BIGINT,
    product_id BIGINT,
    quantity INTEGER,
    unit_price NUMERIC(12, 2),
    line_total NUMERIC(12, 2),
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_payments (
    payment_id BIGINT,
    order_id BIGINT,
    payment_method TEXT,
    payment_status TEXT,
    amount NUMERIC(12, 2),
    paid_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_returns (
    return_id BIGINT,
    order_id BIGINT,
    return_reasons TEXT,
    return_status TEXT,
    return_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT NOW()
);
