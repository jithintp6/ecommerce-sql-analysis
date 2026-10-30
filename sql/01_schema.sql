CREATE DATABASE IF NOT EXISTS ecommerce_analysis;
USE ecommerce_analysis;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (customer_id INT PRIMARY KEY, customer_name VARCHAR(100) NOT NULL, email VARCHAR(150) NOT NULL UNIQUE, city VARCHAR(80), state VARCHAR(80), signup_date DATE);
CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR(120) NOT NULL, category VARCHAR(80), unit_price DECIMAL(12,2) NOT NULL, unit_cost DECIMAL(12,2) NOT NULL);
CREATE TABLE orders (order_id INT PRIMARY KEY, customer_id INT NOT NULL, order_date DATE NOT NULL, order_status VARCHAR(30) NOT NULL, FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
CREATE TABLE order_items (order_item_id INT PRIMARY KEY, order_id INT NOT NULL, product_id INT NOT NULL, quantity INT NOT NULL, unit_price DECIMAL(12,2) NOT NULL, discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0, line_total DECIMAL(12,2) NOT NULL, FOREIGN KEY (order_id) REFERENCES orders(order_id), FOREIGN KEY (product_id) REFERENCES products(product_id));
CREATE TABLE payments (payment_id INT PRIMARY KEY, order_id INT NOT NULL, payment_date DATE NOT NULL, payment_method VARCHAR(40), payment_status VARCHAR(30), amount DECIMAL(12,2) NOT NULL, FOREIGN KEY (order_id) REFERENCES orders(order_id));
-- Import CSVs with MySQL Workbench Table Data Import Wizard, in this order:
-- customers, products, orders, order_items, payments.
