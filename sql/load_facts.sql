TRUNCATE TABLE fact_order_items RESTART IDENTITY;

INSERT INTO fact_order_items (
    order_item_id,
    order_id,
    customer_key,
    product_key,
    order_date_key,
    payment_method_key,
    order_status,
    quantity,
    unit_price,
    line_total
)
SELECT
    oi.order_item_id,
    oi.order_id,
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    dpm.payment_method_key,
    o.order_status,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM stg_order_items oi
JOIN stg_orders o
    ON oi.order_id = o.order_id
JOIN dim_customer dc
    ON o.customer_id = dc.customer_id
    AND dc.is_current = TRUE
JOIN dim_product dp
    ON oi.product_id = dp.product_id
JOIN dim_date dd
    ON o.order_created_at::date = dd.full_date
LEFT JOIN stg_payments p
    ON o.order_id = p.order_id
LEFT JOIN dim_payment_method dpm
    ON p.payment_method = dpm.payment_method;

