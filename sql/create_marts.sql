DROP MATERIALIZED VIEW IF EXISTS mart_sales_by_day;
DROP MATERIALIZED VIEW IF EXISTS mart_top_products;
DROP MATERIALIZED VIEW IF EXISTS mart_customer_ltv;

CREATE MATERIALIZED VIEW mart_sales_by_day AS
SELECT
    d.full_date,
    COUNT(DISTINCT f.order_id) AS orders_count,
    SUM(f.quantity) AS items_sold,
    SUM(f.line_total) AS revenue
FROM fact_order_items f
JOIN dim_date d
    ON f.order_date_key = d.date_key
GROUP BY d.full_date;


CREATE MATERIALIZED VIEW mart_top_products AS
SELECT
    p.product_name,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.line_total) AS revenue
FROM fact_order_items f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY revenue DESC;


CREATE MATERIALIZED VIEW mart_customer_ltv AS
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT f.order_id) AS orders,
    SUM(f.line_total) AS total_spent
FROM fact_order_items f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC;
