CREATE TABLE IF NOT EXISTS fact_order_items (
    order_item_key BIGSERIAL PRIMARY KEY,
    order_item_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,

    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    order_date_key INTEGER NOT NULL,
    payment_method_key BIGINT,

    order_status INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL,
    line_total NUMERIC(14, 2) NOT NULL,

    dwh_loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_fact_order_items_order_item_id
        UNIQUE (order_item_id),

    CONSTRAINT fk_fact_order_items_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer (customer_key),

    CONSTRAINT fk_fact_order_items_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product (product_key),

    CONSTRAINT fk_fact_order_items_date
        FOREIGN KEY (order_date_key)
        REFERENCES dim_date (date_key),

    CONSTRAINT fk_fact_order_items_payment_method
        FOREIGN KEY (payment_method_key)
        REFERENCES dim_payment_method (payment_method_key),

    CONSTRAINT chk_fact_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_fact_order_items_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_fact_order_items_line_total
        CHECK (line_total >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_order_items_customer_key
    ON fact_order_items (customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_order_items_product_key
    ON fact_order_items (product_key);

CREATE INDEX IF NOT EXISTS idx_fact_order_items_order_date_key
    ON fact_order_items (order_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_order_items_order_id
    ON fact_order_items (order_id);