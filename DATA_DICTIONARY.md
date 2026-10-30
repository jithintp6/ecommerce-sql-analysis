# Data Dictionary

| Table | Grain | Key fields |
|---|---|---|
| customers | One row per customer | customer_id (PK), name, email, city, state, signup_date |
| products | One row per product | product_id (PK), product_name, category, unit_price, unit_cost |
| orders | One row per order | order_id (PK), customer_id (FK), order_date, order_status |
| order_items | One row per product line in an order | order_item_id (PK), order_id (FK), product_id (FK), quantity, unit_price, discount_pct, line_total |
| payments | One row per order payment record | payment_id (PK), order_id (FK), payment_date, payment_method, payment_status, amount |

## Assumptions
- Data is synthetic and generated for SQL learning.
- Monetary amounts use generic currency units.
- Revenue analysis includes Delivered orders only.
- line_total includes quantity, unit price and row-level discount.
- unit_cost is synthetic and supports an illustrative gross-profit query only.
- One payment record is generated per order.
