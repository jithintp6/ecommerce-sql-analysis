USE ecommerce_analysis;

-- 1. Order status distribution
SELECT order_status, COUNT(*) AS order_count FROM orders GROUP BY order_status ORDER BY order_count DESC;

-- 2. Delivered revenue
SELECT ROUND(SUM(oi.line_total),2) AS delivered_revenue FROM orders o JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered';

-- 3. Monthly revenue
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS order_month, ROUND(SUM(oi.line_total),2) AS revenue
FROM orders o JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered'
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') ORDER BY order_month;

-- 4. Top 10 products
SELECT p.product_name, SUM(oi.quantity) AS units_sold, ROUND(SUM(oi.line_total),2) AS revenue
FROM products p JOIN order_items oi USING(product_id) JOIN orders o USING(order_id)
WHERE o.order_status='Delivered' GROUP BY p.product_id,p.product_name ORDER BY revenue DESC LIMIT 10;

-- 5. Category revenue
SELECT p.category, ROUND(SUM(oi.line_total),2) AS revenue
FROM products p JOIN order_items oi USING(product_id) JOIN orders o USING(order_id)
WHERE o.order_status='Delivered' GROUP BY p.category ORDER BY revenue DESC;

-- 6. Average order value with a CTE
WITH order_values AS (SELECT o.order_id,SUM(oi.line_total) AS order_value FROM orders o JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered' GROUP BY o.order_id)
SELECT ROUND(AVG(order_value),2) AS average_order_value FROM order_values;

-- 7. Top-spending customers
SELECT c.customer_id,c.customer_name,ROUND(SUM(oi.line_total),2) AS spend
FROM customers c JOIN orders o USING(customer_id) JOIN order_items oi USING(order_id)
WHERE o.order_status='Delivered' GROUP BY c.customer_id,c.customer_name ORDER BY spend DESC LIMIT 10;

-- 8. Repeat customers
SELECT c.customer_id,c.customer_name,COUNT(DISTINCT o.order_id) AS delivered_orders
FROM customers c JOIN orders o USING(customer_id) WHERE o.order_status='Delivered'
GROUP BY c.customer_id,c.customer_name HAVING COUNT(DISTINCT o.order_id)>1 ORDER BY delivered_orders DESC;

-- 9. Customer ranking with RANK
WITH spend AS (SELECT c.customer_id,c.customer_name,SUM(oi.line_total) AS revenue FROM customers c JOIN orders o USING(customer_id) JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered' GROUP BY c.customer_id,c.customer_name)
SELECT *,RANK() OVER(ORDER BY revenue DESC) AS spend_rank FROM spend;

-- 10. Best product in each category with ROW_NUMBER
WITH product_revenue AS (SELECT p.category,p.product_name,SUM(oi.line_total) AS revenue FROM products p JOIN order_items oi USING(product_id) JOIN orders o USING(order_id) WHERE o.order_status='Delivered' GROUP BY p.category,p.product_id,p.product_name),
ranked AS (SELECT *,ROW_NUMBER() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn FROM product_revenue)
SELECT category,product_name,ROUND(revenue,2) AS revenue FROM ranked WHERE rn=1;

-- 11. Cumulative monthly revenue
WITH monthly AS (SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,SUM(oi.line_total) AS revenue FROM orders o JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered' GROUP BY DATE_FORMAT(o.order_date,'%Y-%m'))
SELECT month,ROUND(revenue,2) AS revenue,ROUND(SUM(revenue) OVER(ORDER BY month),2) AS cumulative_revenue FROM monthly ORDER BY month;

-- 12. Month-over-month change with LAG
WITH monthly AS (SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,SUM(oi.line_total) AS revenue FROM orders o JOIN order_items oi USING(order_id) WHERE o.order_status='Delivered' GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')),
lagged AS (SELECT month,revenue,LAG(revenue) OVER(ORDER BY month) AS prev_revenue FROM monthly)
SELECT month,ROUND(revenue,2) AS revenue,ROUND(prev_revenue,2) AS previous_revenue,ROUND(100*(revenue-prev_revenue)/NULLIF(prev_revenue,0),2) AS mom_pct FROM lagged ORDER BY month;

-- 13. Payment methods
SELECT payment_method,payment_status,COUNT(*) AS payment_count,ROUND(SUM(amount),2) AS amount FROM payments GROUP BY payment_method,payment_status ORDER BY amount DESC;

-- 14. Cancellation and return rates
SELECT COUNT(*) AS total_orders,SUM(order_status='Cancelled') AS cancelled_orders,ROUND(100*SUM(order_status='Cancelled')/COUNT(*),2) AS cancellation_pct,SUM(order_status='Returned') AS returned_orders,ROUND(100*SUM(order_status='Returned')/COUNT(*),2) AS return_pct FROM orders;

-- 15. City revenue
SELECT c.city,COUNT(DISTINCT o.order_id) AS delivered_orders,ROUND(SUM(oi.line_total),2) AS revenue
FROM customers c JOIN orders o USING(customer_id) JOIN order_items oi USING(order_id)
WHERE o.order_status='Delivered' GROUP BY c.city ORDER BY revenue DESC;

-- 16. Estimated product gross profit
SELECT p.product_name,ROUND(SUM(oi.quantity*(oi.unit_price-p.unit_cost)),2) AS estimated_gross_profit
FROM products p JOIN order_items oi USING(product_id) JOIN orders o USING(order_id)
WHERE o.order_status='Delivered' GROUP BY p.product_id,p.product_name ORDER BY estimated_gross_profit DESC;

-- 17. Customers with no orders
SELECT c.customer_id,c.customer_name FROM customers c LEFT JOIN orders o USING(customer_id) WHERE o.order_id IS NULL;

-- 18. Products never ordered
SELECT p.product_id,p.product_name FROM products p LEFT JOIN order_items oi USING(product_id) WHERE oi.order_item_id IS NULL;

-- 19. Detailed order summary
SELECT o.order_id,o.order_date,c.customer_name,o.order_status,COUNT(oi.order_item_id) AS line_items,SUM(oi.quantity) AS units,ROUND(SUM(oi.line_total),2) AS order_value
FROM orders o JOIN customers c USING(customer_id) JOIN order_items oi USING(order_id)
GROUP BY o.order_id,o.order_date,c.customer_name,o.order_status ORDER BY o.order_date DESC;
