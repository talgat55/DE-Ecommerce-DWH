import random
from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd
from faker import Faker

fake = Faker()
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = BASE_DIR / "data" / "raw"

def generate_customers(count: int = 500):
    rows = []

    for customer_id in range(1, count + 1):
        rows.append({
            "customer_id": customer_id,
            "first_name": fake.first_name(),
            "last_name": fake.last_name(),
            "email": fake.email(),
            "country": fake.country(),
            "city": fake.city(),
            "registered_at": fake.date_time_between(start_date="-2y", end_date="now"),
        })

    return pd.DataFrame(rows)

def generate_products(count: int = 100):
    categories = ["Electronic", "Clothes", "Books", "Home", "Beauty", "Sports"]
    rows = []

    for product_id in range(1, count + 1):
        rows.append({
            "product_id": product_id,
            "product_name": fake.word().title(),
            "category": random.choice(categories),
            "price": round(random.uniform(5, 500), 2),
            "created_at": fake.date_time_between(start_date="-2y", end_date="now")
        })

    return pd.DataFrame(rows)

def generate_orders(customers_df, count: int = 1000):
    statuses = ["created", "paid", "shipped", "delivered", "cancelled"]
    rows = []

    customer_ids = customers_df["customer_id"].tolist()

    for order_id in range(1, count + 1):
        rows.append({
            "order_id": order_id,
            "customer_id": random.choice(customer_ids),
            "order_status": random.choice(statuses),
            "order_created_at": fake.date_time_between(start_date="-1y", end_date="now"),
        })

    return pd.DataFrame(rows)

def generate_order_items(orders_df, products_df):
    rows = []
    product_ids = products_df['product_id'].tolist()
    product_price_map = dict(zip(products_df["product_id"], products_df["price"]))

    order_item_id = 1

    for order_id in orders_df["order_id"]:
        items_count = random.randint(1,5)

        for _ in range(items_count):
            product_id = random.choice(product_ids)
            quantity = random.randint(1,3)
            unit_price = product_price_map[product_id]

            rows.append({
                "order_item_id": order_item_id,
                "order_id": order_id,
                "product_id": product_id,
                "quantity": quantity,
                "unit_price": unit_price,
                "line_total": round(quantity * unit_price, 2),
            })

            order_item_id +=1

    return pd.DataFrame(rows)

def generate_payments(orders_df, order_items_df):
    methods = ["card", "paypal", "bank_transfer", "cash"]
    statuses = ["success", "failed", "refunded"]

    order_total_map = (
        order_items_df
            .groupby("order_id")["line_total"]
            .sum()
            .to_dict()
    )

    rows = []

    for payment_id, order_id in enumerate(orders_df["order_id"], start=1):
        rows.append({
            "payment_id": payment_id,
            "order_id": order_id,
            "payment_method": random.choice(methods),
            "payment_status": random.choice(statuses),
            "amount": round(order_total_map.get(order_id, 0), 2),
            "paid_at": fake.date_time_between(start_date="-1y", end_date="now"),
        })

    return pd.DataFrame(rows)

def generate_returns(orders_df, max_returns: int = 150):
    reasons = ["damaged", "wrong_size", "later_delivery", "changed_mind", "other"]
    delivered_orders = orders_df[orders_df["order_status"] == "delivered"]

    sample_size = min(max_returns, len(delivered_orders))

    if sample_size == 0:
        return pd.DataFrame(columns=[
            "return_id", "order_id", "return_reason", "return_status", "returned_at"
        ])

    sampled_orders = delivered_orders.sample(sample_size)

    rows = []

    for return_id, order_id in enumerate(sampled_orders["order_id"], start=1):
        rows.append({
            "return_id": return_id,
            "order_id": order_id,
            "return_reasons": random.choice(reasons),
            "return_status": random.choice(["requested", "approved", "rejected", "completed"]),
            "return_at": fake.date_time_between(start_date="-1y", end_date="now"),
        })

    return pd.DataFrame(rows)

def save_csv(df: pd.DataFrame, filename: str):
    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = RAW_DATA_DIR / filename
    df.to_csv(path, index=False)
    print(f"Saved {path} rows={len(df)}")

def generate_all():
    customers = generate_customers()
    products = generate_products()
    orders = generate_orders(customers)
    order_items = generate_order_items(orders, products)
    payments = generate_payments(orders, order_items)
    returns = generate_returns(orders)

    save_csv(customers, "customers.csv")
    save_csv(products, "products.csv")
    save_csv(orders, "orders.csv")
    save_csv(order_items, "order_items.csv")
    save_csv(payments, "payments.csv")
    save_csv(returns, "returns.csv")

if __name__ == "__main__":
    generate_all()