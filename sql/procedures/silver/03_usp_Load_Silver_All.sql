/******************************************************************************
Project     : Olist Data Warehouse & Analytics
File        : usp_Load_Silver_All.sql
Layer       : Silver
Database    : OlistDW

Description :
    Master orchestration procedure for the Silver layer.

    Executes the complete Silver ETL process by:
        1. Loading all dimension tables
        2. Loading all fact tables

    This procedure should be used as the primary entry point
    for refreshing the Silver layer.

Procedures Called:
    silver.usp_Load_Silver_Dimensions
    silver.usp_Load_Silver_Facts

Load Strategy:
    Full Refresh

Use:
	EXEC silver.usp_Load_Silver_All
******************************************************************************/

USE OlistDW;
GO

CREATE OR ALTER PROCEDURE silver.usp_Load_Silver_All
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ----------------------------------------------------
        -- Delete Fact Tables
        ----------------------------------------------------

        DELETE FROM silver.order_reviews;
        DELETE FROM silver.order_payments;
        DELETE FROM silver.order_items;
        DELETE FROM silver.orders;

        ----------------------------------------------------
        -- Delete Dimension Tables
        ----------------------------------------------------

        DELETE FROM silver.products;
        DELETE FROM silver.product_category_name_translation;
        DELETE FROM silver.sellers;
        DELETE FROM silver.geolocation;
        DELETE FROM silver.customers;

        ----------------------------------------------------
        -- Load
        ----------------------------------------------------

		PRINT '============================================================';
		PRINT '              Olist Data Warehouse';
		PRINT '            Silver Layer ETL Process';
		PRINT '============================================================';
		PRINT '';

		PRINT 'Step 1 of 2 : Loading Dimension Tables';
		PRINT '--------------------------------------';

		EXEC silver.usp_Load_Silver_Dimensions;

		PRINT '';

		PRINT 'Step 2 of 2 : Loading Fact Tables';
		PRINT '---------------------------------';

		EXEC silver.usp_Load_Silver_Facts;

		PRINT '';

		PRINT '============================================================';
		PRINT 'Silver Layer ETL Completed Successfully';
		PRINT '============================================================';

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;

    END CATCH

END;
GO