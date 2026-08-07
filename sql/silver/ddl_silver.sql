/******************************************************************************
Project     : Olist Data Warehouse & Analytics
File        : ddl_silver.sql
Layer       : Silver
Database    : OlistDW

Description :
    Creates the Silver layer tables for the Olist Data Warehouse.

    The Silver layer stores cleaned, standardized, and validated data
    loaded from the Bronze layer.

******************************************************************************/

USE OlistDW;
GO

/*==============================================================
  Drop Existing Tables
  (Reverse Dependency Order)
==============================================================*/

DROP TABLE IF EXISTS silver.order_reviews;
DROP TABLE IF EXISTS silver.order_payments;
DROP TABLE IF EXISTS silver.order_items;
DROP TABLE IF EXISTS silver.orders;
DROP TABLE IF EXISTS silver.products;
DROP TABLE IF EXISTS silver.product_category_name_translation;
DROP TABLE IF EXISTS silver.sellers;
DROP TABLE IF EXISTS silver.geolocation;
DROP TABLE IF EXISTS silver.customers;
GO

/*==============================================================
  Create Table : customers
==============================================================*/

CREATE TABLE silver.customers
(
    customer_id                 NVARCHAR(50) NOT NULL,
    customer_unique_id          NVARCHAR(50) NOT NULL,
    customer_zip_code_prefix    INT NULL,
    customer_city               NVARCHAR(100) NULL,
    customer_state              CHAR(2) NULL
);
GO

/*==============================================================
  Create Table : geolocation
==============================================================*/

CREATE TABLE silver.geolocation
(
    geolocation_zip_code_prefix INT NOT NULL,
    geolocation_lat             DECIMAL(9,6) NOT NULL,
    geolocation_lng             DECIMAL(9,6) NOT NULL,
    geolocation_city            NVARCHAR(100) NULL,
    geolocation_state           CHAR(2) NULL
);
GO

/*==============================================================
  Create Table : sellers
==============================================================*/

CREATE TABLE silver.sellers
(
    seller_id                   NVARCHAR(50) NOT NULL,
    seller_zip_code_prefix      INT NULL,
    seller_city                 NVARCHAR(100) NULL,
    seller_state                CHAR(2) NULL
);
GO

/*==============================================================
  Create Table :
  product_category_name_translation
==============================================================*/

CREATE TABLE silver.product_category_name_translation
(
    product_category_name           NVARCHAR(100) NOT NULL,
    product_category_name_english   NVARCHAR(100) NOT NULL
);
GO

/*==============================================================
  Create Table : products
==============================================================*/

CREATE TABLE silver.products
(
    product_id                      NVARCHAR(50) NOT NULL,

    product_category_name           NVARCHAR(100) NULL,

    product_name_length             INT NULL,
    product_description_length      INT NULL,

    product_photos_qty              INT NULL,

    product_weight_g                DECIMAL(10,2) NULL,

    product_length_cm               DECIMAL(10,2) NULL,
    product_height_cm               DECIMAL(10,2) NULL,
    product_width_cm                DECIMAL(10,2) NULL
);
GO

/*==============================================================
  Create Table : orders
==============================================================*/

CREATE TABLE silver.orders
(
    order_id                        NVARCHAR(50) NOT NULL,
    customer_id                     NVARCHAR(50) NOT NULL,

    order_status                    NVARCHAR(20) NOT NULL,

    order_purchase_timestamp        DATETIME2 NULL,
    order_approved_at               DATETIME2 NULL,
    order_delivered_carrier_date    DATETIME2 NULL,
    order_delivered_customer_date   DATETIME2 NULL,
    order_estimated_delivery_date   DATETIME2 NULL
);
GO

/*==============================================================
  Create Table : order_items
==============================================================*/

CREATE TABLE silver.order_items
(
    order_id                NVARCHAR(50) NOT NULL,
    order_item_id           INT NOT NULL,

    product_id              NVARCHAR(50) NOT NULL,
    seller_id               NVARCHAR(50) NOT NULL,

    shipping_limit_date     DATETIME2 NULL,

    price                   DECIMAL(10,2) NOT NULL,
    freight_value           DECIMAL(10,2) NOT NULL
);
GO

/*==============================================================
  Create Table : order_payments
==============================================================*/

CREATE TABLE silver.order_payments
(
    order_id                    NVARCHAR(50) NOT NULL,

    payment_sequential          INT NOT NULL,

    payment_type                NVARCHAR(30) NOT NULL,

    payment_installments        INT NOT NULL,

    payment_value               DECIMAL(10,2) NOT NULL
);
GO

/*==============================================================
  Create Table : order_reviews
==============================================================*/

CREATE TABLE silver.order_reviews
(
    review_id                   NVARCHAR(50) NOT NULL,

    order_id                    NVARCHAR(50) NOT NULL,

    review_score                INT NOT NULL,

    review_comment_title        NVARCHAR(255) NULL,

    review_comment_message      NVARCHAR(MAX) NULL,

    review_creation_date        DATETIME2 NULL,

    review_answer_timestamp     DATETIME2 NULL
);
GO

/******************************************************************************
    Primary Keys
******************************************************************************/

ALTER TABLE silver.customers
ADD CONSTRAINT PK_silver_customers
PRIMARY KEY CLUSTERED (customer_id);
GO

ALTER TABLE silver.geolocation
ADD CONSTRAINT PK_silver_geolocation
PRIMARY KEY CLUSTERED
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng
);
GO

ALTER TABLE silver.sellers
ADD CONSTRAINT PK_silver_sellers
PRIMARY KEY CLUSTERED (seller_id);
GO

ALTER TABLE silver.product_category_name_translation
ADD CONSTRAINT PK_silver_product_category_name_translation
PRIMARY KEY CLUSTERED (product_category_name);
GO

ALTER TABLE silver.products
ADD CONSTRAINT PK_silver_products
PRIMARY KEY CLUSTERED (product_id);
GO

ALTER TABLE silver.orders
ADD CONSTRAINT PK_silver_orders
PRIMARY KEY CLUSTERED (order_id);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT PK_silver_order_items
PRIMARY KEY CLUSTERED
(
    order_id,
    order_item_id
);
GO

ALTER TABLE silver.order_payments
ADD CONSTRAINT PK_silver_order_payments
PRIMARY KEY CLUSTERED
(
    order_id,
    payment_sequential
);
GO

ALTER TABLE silver.order_reviews
ADD CONSTRAINT PK_silver_order_reviews
PRIMARY KEY CLUSTERED (review_id);
GO


/******************************************************************************
    Foreign Keys
******************************************************************************/

ALTER TABLE silver.products
ADD CONSTRAINT FK_products_category
FOREIGN KEY (product_category_name)
REFERENCES silver.product_category_name_translation
(
    product_category_name
);
GO

ALTER TABLE silver.orders
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (customer_id)
REFERENCES silver.customers(customer_id);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT FK_order_items_orders
FOREIGN KEY (order_id)
REFERENCES silver.orders(order_id);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (product_id)
REFERENCES silver.products(product_id);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT FK_order_items_sellers
FOREIGN KEY (seller_id)
REFERENCES silver.sellers(seller_id);
GO

ALTER TABLE silver.order_payments
ADD CONSTRAINT FK_order_payments_orders
FOREIGN KEY (order_id)
REFERENCES silver.orders(order_id);
GO

ALTER TABLE silver.order_reviews
ADD CONSTRAINT FK_order_reviews_orders
FOREIGN KEY (order_id)
REFERENCES silver.orders(order_id);
GO


/******************************************************************************
    Check Constraints
******************************************************************************/

ALTER TABLE silver.products
ADD CONSTRAINT CK_products_weight
CHECK (product_weight_g IS NULL OR product_weight_g >= 0);
GO

ALTER TABLE silver.products
ADD CONSTRAINT CK_products_length
CHECK (product_length_cm IS NULL OR product_length_cm >= 0);
GO

ALTER TABLE silver.products
ADD CONSTRAINT CK_products_height
CHECK (product_height_cm IS NULL OR product_height_cm >= 0);
GO

ALTER TABLE silver.products
ADD CONSTRAINT CK_products_width
CHECK (product_width_cm IS NULL OR product_width_cm >= 0);
GO

ALTER TABLE silver.products
ADD CONSTRAINT CK_products_photos
CHECK (product_photos_qty IS NULL OR product_photos_qty >= 0);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT CK_order_items_price
CHECK (price >= 0);
GO

ALTER TABLE silver.order_items
ADD CONSTRAINT CK_order_items_freight
CHECK (freight_value >= 0);
GO

ALTER TABLE silver.order_payments
ADD CONSTRAINT CK_order_payments_installments
CHECK (payment_installments >= 1);
GO

ALTER TABLE silver.order_payments
ADD CONSTRAINT CK_order_payments_value
CHECK (payment_value >= 0);
GO

ALTER TABLE silver.order_reviews
ADD CONSTRAINT CK_order_reviews_score
CHECK (review_score BETWEEN 1 AND 5);
GO


/******************************************************************************
    Non-Clustered Indexes
******************************************************************************/

CREATE INDEX IX_customers_customer_unique_id
ON silver.customers(customer_unique_id);
GO

CREATE INDEX IX_customers_zip_code
ON silver.customers(customer_zip_code_prefix);
GO

CREATE INDEX IX_sellers_zip_code
ON silver.sellers(seller_zip_code_prefix);
GO

CREATE INDEX IX_products_category
ON silver.products(product_category_name);
GO

CREATE INDEX IX_orders_customer
ON silver.orders(customer_id);
GO

CREATE INDEX IX_orders_status
ON silver.orders(order_status);
GO

CREATE INDEX IX_order_items_product
ON silver.order_items(product_id);
GO

CREATE INDEX IX_order_items_seller
ON silver.order_items(seller_id);
GO

CREATE INDEX IX_order_payments_type
ON silver.order_payments(payment_type);
GO

CREATE INDEX IX_order_reviews_order
ON silver.order_reviews(order_id);
GO

