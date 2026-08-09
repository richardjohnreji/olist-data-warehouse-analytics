/*==============================================================
  Gold Key Mapping Tables
  Purpose:
      Store stable business display keys for reporting while
      preserving the original business keys.
==============================================================*/


/*==============================================================
  Customer Key Mapping
==============================================================*/

USE OlistDW;
GO

IF OBJECT_ID('gold.customer_key_map', 'U') IS NULL
BEGIN

    CREATE TABLE gold.customer_key_map
    (
        customer_key CHAR(9) NOT NULL,
        customer_id VARCHAR(50) NOT NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_customer_key_map_created_at
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_customer_key_map
            PRIMARY KEY (customer_key),

        CONSTRAINT UQ_customer_key_map_customer_id
            UNIQUE (customer_id)
    );

END;
GO


/*==============================================================
  Product Key Mapping
==============================================================*/

IF OBJECT_ID('gold.product_key_map', 'U') IS NULL
BEGIN

    CREATE TABLE gold.product_key_map
    (
        product_key CHAR(9) NOT NULL,
        product_id VARCHAR(50) NOT NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_product_key_map_created_at
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_product_key_map
            PRIMARY KEY (product_key),

        CONSTRAINT UQ_product_key_map_product_id
            UNIQUE (product_id)
    );

END;
GO


/*==============================================================
  Seller Key Mapping
==============================================================*/

IF OBJECT_ID('gold.seller_key_map', 'U') IS NULL
BEGIN

    CREATE TABLE gold.seller_key_map
    (
        seller_key CHAR(9) NOT NULL,
        seller_id VARCHAR(50) NOT NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_seller_key_map_created_at
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_seller_key_map
            PRIMARY KEY (seller_key),

        CONSTRAINT UQ_seller_key_map_seller_id
            UNIQUE (seller_id)
    );

END;
GO


/*==============================================================
  Order Key Mapping
==============================================================*/

IF OBJECT_ID('gold.order_key_map', 'U') IS NULL
BEGIN

    CREATE TABLE gold.order_key_map
    (
        order_key CHAR(9) NOT NULL,
        order_id VARCHAR(50) NOT NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_order_key_map_created_at
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_order_key_map
            PRIMARY KEY (order_key),

        CONSTRAINT UQ_order_key_map_order_id
            UNIQUE (order_id)
    );

END;
GO


PRINT '=========================================';
PRINT 'Gold Key Mapping Tables Created';
PRINT '=========================================';
GO