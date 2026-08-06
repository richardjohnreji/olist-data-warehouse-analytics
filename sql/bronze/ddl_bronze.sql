/*
===============================================================================
Project     : Olist Brazilian E-commerce Data Warehouse
Script      : 02_ddl_bronze.sql
Description : Creates all Bronze layer tables.

Execution:
    - Run after 01_ddl_database.sql

Notes:
    - Bronze stores raw data from the source system.
    - Minimal constraints are applied.
    - Data types are intentionally flexible to support ingestion.
===============================================================================
*/

USE OlistDW;
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- Table: bronze.customers
-- Description: Raw customer information
-- ============================================================================

CREATE TABLE bronze.customers
(
    customer_id                 NVARCHAR(255) NULL,
    customer_unique_id          NVARCHAR(255) NULL,
    customer_zip_code_prefix    NVARCHAR(255) NULL,
    customer_city               NVARCHAR(255) NULL,
    customer_state              NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.geolocation
-- Description: Raw geolocation information
-- ============================================================================

CREATE TABLE bronze.geolocation
(
    geolocation_zip_code_prefix NVARCHAR(255) NULL,
    geolocation_lat             NVARCHAR(255) NULL,
    geolocation_lng             NVARCHAR(255) NULL,
    geolocation_city            NVARCHAR(255) NULL,
    geolocation_state           NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.sellers
-- Description: Raw seller information
-- ============================================================================

CREATE TABLE bronze.sellers
(
    seller_id                  NVARCHAR(255) NULL,
    seller_zip_code_prefix     NVARCHAR(255) NULL,
    seller_city                NVARCHAR(255) NULL,
    seller_state               NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.products
-- Description: Raw product information
-- ============================================================================

CREATE TABLE bronze.products
(
    product_id                     NVARCHAR(255) NULL,
    product_category_name          NVARCHAR(255) NULL,
    product_name_length            NVARCHAR(255) NULL,
    product_description_length     NVARCHAR(255) NULL,
    product_photos_qty             NVARCHAR(255) NULL,
    product_weight_g               NVARCHAR(255) NULL,
    product_length_cm              NVARCHAR(255) NULL,
    product_height_cm              NVARCHAR(255) NULL,
    product_width_cm               NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.product_category_name_translation
-- Description: Raw category translation lookup
-- ============================================================================

CREATE TABLE bronze.product_category_name_translation
(
    product_category_name          NVARCHAR(255) NULL,
    product_category_name_english  NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.orders
-- Description: Raw order information
-- ============================================================================

CREATE TABLE bronze.orders
(
    order_id                         NVARCHAR(255) NULL,
    customer_id                      NVARCHAR(255) NULL,
    order_status                     NVARCHAR(255) NULL,
    order_purchase_timestamp         NVARCHAR(255) NULL,
    order_approved_at                NVARCHAR(255) NULL,
    order_delivered_carrier_date     NVARCHAR(255) NULL,
    order_delivered_customer_date    NVARCHAR(255) NULL,
    order_estimated_delivery_date    NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.order_items
-- Description: Raw order item information
-- ============================================================================

CREATE TABLE bronze.order_items
(
    order_id                NVARCHAR(255) NULL,
    order_item_id           NVARCHAR(255) NULL,
    product_id              NVARCHAR(255) NULL,
    seller_id               NVARCHAR(255) NULL,
    shipping_limit_date     NVARCHAR(255) NULL,
    price                   NVARCHAR(255) NULL,
    freight_value           NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.order_payments
-- Description: Raw payment information
-- ============================================================================

CREATE TABLE bronze.order_payments
(
    order_id                   NVARCHAR(255) NULL,
    payment_sequential         NVARCHAR(255) NULL,
    payment_type               NVARCHAR(255) NULL,
    payment_installments       NVARCHAR(255) NULL,
    payment_value              NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Table: bronze.order_reviews
-- Description: Raw customer review information
-- ============================================================================

CREATE TABLE bronze.order_reviews
(
    review_id                    NVARCHAR(255) NULL,
    order_id                     NVARCHAR(255) NULL,
    review_score                 NVARCHAR(255) NULL,
    review_comment_title         NVARCHAR(255) NULL,
    review_comment_message       NVARCHAR(MAX) NULL,
    review_creation_date         NVARCHAR(255) NULL,
    review_answer_timestamp      NVARCHAR(255) NULL
);
GO

-- ============================================================================
-- Bronze Layer Creation Complete
-- ============================================================================

PRINT '==============================================';
PRINT 'Bronze Layer Created Successfully';
PRINT '==============================================';
GO
