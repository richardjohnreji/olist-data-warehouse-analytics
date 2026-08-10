/*==============================================================
  Procedure: gold.usp_Load_Key_Mappings

  Purpose:
      Incrementally load stable business display keys for
      Customers, Products, Sellers and Orders.

  Features:
      • Incremental loading
      • Stable business keys
      • Idempotent execution
      • Transaction support
      • ETL logging
      • Error handling

	Use:
	  • EXEC gold.usp_Load_Key_Mappings
==============================================================*/

USE OlistDW;
GO

CREATE OR ALTER PROCEDURE gold.usp_Load_Key_Mappings
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @CustomerRowsInserted INT = 0,
        @ProductRowsInserted  INT = 0,
        @SellerRowsInserted   INT = 0,
        @OrderRowsInserted    INT = 0;

    BEGIN TRY

        BEGIN TRANSACTION;

        PRINT '=========================================';
        PRINT 'Loading Gold Key Mapping Tables';
        PRINT '=========================================';

        /*======================================================
            Customer Key Mapping
        ======================================================*/

        PRINT 'Loading Customer Key Mapping...';

        DECLARE @CustomerStart INT;

        SELECT
            @CustomerStart =
            ISNULL(MAX(CAST(SUBSTRING(customer_key,2,8) AS INT)),0)
        FROM gold.customer_key_map;

        ;WITH NewCustomers AS
        (
            SELECT
                c.customer_id,
                ROW_NUMBER() OVER (ORDER BY c.customer_id) AS rn
            FROM silver.customers c
            LEFT JOIN gold.customer_key_map m
                ON c.customer_id = m.customer_id
            WHERE m.customer_id IS NULL
        )

        INSERT INTO gold.customer_key_map
        (
            customer_key,
            customer_id
        )

        SELECT

            CONCAT
            (
                'C',
                RIGHT('00000000'
                + CAST(@CustomerStart + rn AS VARCHAR(8)),8)
            ),

            customer_id

        FROM NewCustomers;

        SET @CustomerRowsInserted = @@ROWCOUNT;

        PRINT CONCAT('Customers Loaded : ', @CustomerRowsInserted);



        /*======================================================
            Product Key Mapping
        ======================================================*/

        PRINT 'Loading Product Key Mapping...';

        DECLARE @ProductStart INT;

        SELECT
            @ProductStart =
            ISNULL(MAX(CAST(SUBSTRING(product_key,2,8) AS INT)),0)
        FROM gold.product_key_map;

        ;WITH NewProducts AS
        (
            SELECT
                p.product_id,
                ROW_NUMBER() OVER (ORDER BY p.product_id) AS rn
            FROM silver.products p
            LEFT JOIN gold.product_key_map m
                ON p.product_id = m.product_id
            WHERE m.product_id IS NULL
        )

        INSERT INTO gold.product_key_map
        (
            product_key,
            product_id
        )

        SELECT

            CONCAT
            (
                'P',
                RIGHT('00000000'
                + CAST(@ProductStart + rn AS VARCHAR(8)),8)
            ),

            product_id

        FROM NewProducts;

        SET @ProductRowsInserted = @@ROWCOUNT;

        PRINT CONCAT('Products Loaded  : ', @ProductRowsInserted);



        /*======================================================
            Seller Key Mapping
        ======================================================*/

        PRINT 'Loading Seller Key Mapping...';

        DECLARE @SellerStart INT;

        SELECT
            @SellerStart =
            ISNULL(MAX(CAST(SUBSTRING(seller_key,2,8) AS INT)),0)
        FROM gold.seller_key_map;

        ;WITH NewSellers AS
        (
            SELECT
                s.seller_id,
                ROW_NUMBER() OVER (ORDER BY s.seller_id) AS rn
            FROM silver.sellers s
            LEFT JOIN gold.seller_key_map m
                ON s.seller_id = m.seller_id
            WHERE m.seller_id IS NULL
        )

        INSERT INTO gold.seller_key_map
        (
            seller_key,
            seller_id
        )

        SELECT

            CONCAT
            (
                'S',
                RIGHT('00000000'
                + CAST(@SellerStart + rn AS VARCHAR(8)),8)
            ),

            seller_id

        FROM NewSellers;

        SET @SellerRowsInserted = @@ROWCOUNT;

        PRINT CONCAT('Sellers Loaded   : ', @SellerRowsInserted);



        /*======================================================
            Order Key Mapping
        ======================================================*/

        PRINT 'Loading Order Key Mapping...';

        DECLARE @OrderStart INT;

        SELECT
            @OrderStart =
            ISNULL(MAX(CAST(SUBSTRING(order_key,2,8) AS INT)),0)
        FROM gold.order_key_map;

        ;WITH NewOrders AS
        (
            SELECT
                o.order_id,
                ROW_NUMBER() OVER (ORDER BY o.order_id) AS rn
            FROM silver.orders o
            LEFT JOIN gold.order_key_map m
                ON o.order_id = m.order_id
            WHERE m.order_id IS NULL
        )

        INSERT INTO gold.order_key_map
        (
            order_key,
            order_id
        )

        SELECT

            CONCAT
            (
                'O',
                RIGHT('00000000'
                + CAST(@OrderStart + rn AS VARCHAR(8)),8)
            ),

            order_id

        FROM NewOrders;

        SET @OrderRowsInserted = @@ROWCOUNT;

        PRINT CONCAT('Orders Loaded    : ', @OrderRowsInserted);



        COMMIT TRANSACTION;

        PRINT '';
        PRINT '=========================================';
        PRINT 'Gold Key Mapping Load Summary';
        PRINT '=========================================';
        PRINT CONCAT('Customers Loaded : ', @CustomerRowsInserted);
        PRINT CONCAT('Products Loaded  : ', @ProductRowsInserted);
        PRINT CONCAT('Sellers Loaded   : ', @SellerRowsInserted);
        PRINT CONCAT('Orders Loaded    : ', @OrderRowsInserted);
        PRINT '=========================================';
        PRINT 'Gold Key Mapping Completed Successfully.';
        PRINT '=========================================';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH

END;
GO