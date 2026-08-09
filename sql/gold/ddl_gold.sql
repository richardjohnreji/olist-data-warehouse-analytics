USE OlistDW;
GO	

CREATE OR ALTER VIEW gold.dim_customers
AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM silver.customers;
GO

CREATE OR ALTER VIEW gold.dim_products
AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, '[Missing Translation]') AS product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM silver.products AS p
LEFT JOIN silver.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name;
GO

CREATE OR ALTER VIEW gold.dim_sellers
AS
SELECT
    seller_id,
    seller_city,
    seller_state
FROM silver.sellers;
GO

CREATE OR ALTER VIEW gold.fact_sales
AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_sales_amount
FROM silver.order_items AS oi
INNER JOIN silver.orders AS o
    ON oi.order_id = o.order_id;
GO

CREATE OR ALTER VIEW gold.dim_dates
AS

SELECT

    calendar_date      AS [date],

    calendar_year      AS [year],

    calendar_quarter   AS quarter,

    calendar_month     AS month,

    month_name,

    day_of_month       AS day,

    day_of_week,

    weekday_name       AS weekday,

    is_weekend

FROM gold.calendar;
GO