/*==============================================================
  Gold Semantic Views
  Purpose:
      Expose business-friendly dimensions and fact views for
      reporting and Power BI.
==============================================================*/


/*==============================================================
  Customer Dimension
==============================================================*/

USE OlistDW;
GO

CREATE OR ALTER VIEW gold.dim_customers
AS

SELECT

    km.customer_key,

    c.customer_id,

    c.customer_unique_id,

    c.customer_city  AS city,

    c.customer_state AS state

FROM silver.customers AS c

INNER JOIN gold.customer_key_map AS km
    ON c.customer_id = km.customer_id;
GO


/*==============================================================
  Product Dimension
==============================================================*/

CREATE OR ALTER VIEW gold.dim_products
AS

SELECT

    km.product_key,

    p.product_id,

    COALESCE
    (
        t.product_category_name_english,
        '[Missing Translation]'
    ) AS category,

    p.product_weight_g AS weight_g,

    p.product_length_cm AS length_cm,

    p.product_height_cm AS height_cm,

    p.product_width_cm AS width_cm

FROM silver.products AS p

INNER JOIN gold.product_key_map AS km
    ON p.product_id = km.product_id

LEFT JOIN silver.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name;
GO


/*==============================================================
  Seller Dimension
==============================================================*/

CREATE OR ALTER VIEW gold.dim_sellers
AS

SELECT

    km.seller_key,

    s.seller_id,

    s.seller_city  AS city,

    s.seller_state AS state

FROM silver.sellers AS s

INNER JOIN gold.seller_key_map AS km
    ON s.seller_id = km.seller_id;
GO


/*==============================================================
  Date Dimension
==============================================================*/

CREATE OR ALTER VIEW gold.dim_dates
AS

SELECT

    calendar_date AS [date],

    calendar_year AS [year],

    calendar_quarter AS quarter,

    calendar_month AS month,

    month_name,

    day_of_month AS day,

    day_of_week,

    weekday_name AS weekday,

    CASE
        WHEN is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    is_weekend

FROM gold.calendar;
GO


/*==============================================================
  Sales Fact
==============================================================*/

CREATE OR ALTER VIEW gold.fact_sales
AS

SELECT

    okm.order_key,

    ckm.customer_key,

    pkm.product_key,

    skm.seller_key,

    oi.order_id,

    oi.order_item_id,

    o.customer_id,

    oi.product_id,

    oi.seller_id,

    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,

    oi.price AS product_price,

    oi.freight_value AS freight_cost,

    oi.price + oi.freight_value AS total_sales

FROM silver.order_items AS oi

INNER JOIN silver.orders AS o
    ON oi.order_id = o.order_id

INNER JOIN gold.order_key_map AS okm
    ON oi.order_id = okm.order_id

INNER JOIN gold.customer_key_map AS ckm
    ON o.customer_id = ckm.customer_id

INNER JOIN gold.product_key_map AS pkm
    ON oi.product_id = pkm.product_id

INNER JOIN gold.seller_key_map AS skm
    ON oi.seller_id = skm.seller_id;
GO


PRINT '=========================================';
PRINT 'Gold Semantic Views Updated Successfully';
PRINT '=========================================';
GO