-- =============================================================
-- Create Database and Tables (MySQL Version)
-- =============================================================
-- Script Purpose:
--     This script creates a new database named 'DataWarehouseAnalytics'
--     after dropping it if it already exists. It then creates three tables
--     (dim_customers, dim_products, fact_sales) and loads data from CSV files.
--
-- WARNING:
--     Running this script will drop the entire 'DataWarehouseAnalytics'
--     database if it exists. All data will be permanently deleted.
--     Ensure you have proper backups before running this script.
--
-- NOTE on LOAD DATA INFILE paths:
--     The CSV paths below reference /tmp/csv-files/ inside the container.
--     Before running this script, copy your CSV files into the container with:
--
--       docker cp datasets/csv-files/gold.dim_customers.csv my-mysql:/var/lib/mysql-files/gold.dim_customers.csv
--       docker cp datasets/csv-files/gold.dim_products.csv  my-mysql:/var/lib/mysql-files/gold.dim_products.csv
--       docker cp datasets/csv-files/gold.fact_sales.csv    my-mysql:/var/lib/mysql-files/gold.fact_sales.csv
-- =============================================================

-- Drop and recreate the database
DROP DATABASE IF EXISTS DataWarehouseAnalytics;
CREATE DATABASE DataWarehouseAnalytics;
USE DataWarehouseAnalytics;

-- -------------------------------------------------------
-- Table: dim_customers
-- -------------------------------------------------------
CREATE TABLE dim_customers (
    customer_key     INT,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE NULL,
    create_date      DATE NULL
);

-- -------------------------------------------------------
-- Table: dim_products
-- -------------------------------------------------------
CREATE TABLE dim_products (
    product_key     INT,
    product_id      INT,
    product_number  VARCHAR(50),
    product_name    VARCHAR(50),
    category_id     VARCHAR(50),
    category        VARCHAR(50),
    subcategory     VARCHAR(50),
    maintenance     VARCHAR(50),
    cost            INT,
    product_line    VARCHAR(50),
    start_date      DATE NULL
);

-- -------------------------------------------------------
-- Table: fact_sales
-- -------------------------------------------------------
CREATE TABLE fact_sales (
    order_number   VARCHAR(50),
    product_key    INT,
    customer_key   INT,
    order_date     DATE NULL,
    shipping_date  DATE NULL,
    due_date       DATE NULL,
    sales_amount   INT,
    quantity       TINYINT,
    price          INT
);

-- -------------------------------------------------------
-- Load data from CSV files
-- (Files must be copied into the container first — see header notes)
-- -------------------------------------------------------

TRUNCATE TABLE dim_customers;
LOAD DATA INFILE '/var/lib/mysql-files/gold.dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_key, customer_id, customer_number, first_name, last_name,
 country, marital_status, gender, @birthdate, @create_date)
SET
    birthdate   = NULLIF(@birthdate, ''),
    create_date = NULLIF(@create_date, '');

TRUNCATE TABLE dim_products;
LOAD DATA INFILE '/var/lib/mysql-files/gold.dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_key, product_id, product_number, product_name, category_id,
 category, subcategory, maintenance, cost, product_line, @start_date)
SET
    start_date = NULLIF(@start_date, '');

TRUNCATE TABLE fact_sales;
LOAD DATA INFILE '/var/lib/mysql-files/gold.fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_number, product_key, customer_key, @order_date, @shipping_date,
 @due_date, sales_amount, quantity, price)
SET
    order_date    = NULLIF(@order_date, ''),
    shipping_date = NULLIF(@shipping_date, ''),
    due_date      = NULLIF(@due_date, '');
