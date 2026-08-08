/******************************************************************************
Project     : Olist Data Warehouse & Analytics
File        : usp_Load_Silver_Dimensions.sql
Layer       : Silver
Database    : OlistDW

Description :
    Loads and transforms all dimension tables from the Bronze layer
    into the Silver layer.

Source:
    bronze.customers
    bronze.geolocation
    bronze.sellers
    bronze.product_category_name_translation
    bronze.products

Target:
    silver.customers
    silver.geolocation
    silver.sellers
    silver.product_category_name_translation
    silver.products

Load Strategy:
    Full Refresh (orchestrated by usp_Load_Silver_All)

******************************************************************************/

USE OlistDW;
GO

CREATE OR ALTER PROCEDURE silver.usp_Load_Silver_Dimensions
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ------------------------------------------------------------
    -- Row Count Variables
    ------------------------------------------------------------

    DECLARE @CustomersLoaded INT = 0;
    DECLARE @GeolocationLoaded INT = 0;
    DECLARE @SellersLoaded INT = 0;
    DECLARE @CategoriesLoaded INT = 0;
    DECLARE @ProductsLoaded INT = 0;

    BEGIN TRY

        /***********************************************************
            Load Customers
        ************************************************************/

		PRINT 'Loading silver.customers...';

        INSERT INTO silver.customers
        (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        )
        SELECT
            customer_id,
            TRIM(customer_unique_id),
            customer_zip_code_prefix,
            TRIM(customer_city),
            UPPER(TRIM(customer_state))
        FROM bronze.customers
        WHERE customer_id IS NOT NULL;

        SET @CustomersLoaded = @@ROWCOUNT;

		PRINT 'Customers Loaded : ' + CAST(@CustomersLoaded AS VARCHAR(20));
		PRINT '';

        /***********************************************************
			Load Geolocation
		************************************************************/

		PRINT 'Loading silver.geolocation...';

		;WITH Geo AS
		(
			SELECT
				geolocation_zip_code_prefix,
				ROUND(CAST(geolocation_lat AS DECIMAL(18,15)), 6) AS rounded_lat,
				ROUND(CAST(geolocation_lng AS DECIMAL(18,15)), 6) AS rounded_lng,
				TRIM(geolocation_city) AS geolocation_city,
				UPPER(TRIM(geolocation_state)) AS geolocation_state
			FROM bronze.geolocation
		),
		GeoDedup AS
		(
			SELECT
				*,
				ROW_NUMBER() OVER
				(
					PARTITION BY
						geolocation_zip_code_prefix,
						rounded_lat,
						rounded_lng
					ORDER BY geolocation_city
				) AS rn
			FROM Geo
		)

		INSERT INTO silver.geolocation
		(
			geolocation_zip_code_prefix,
			geolocation_lat,
			geolocation_lng,
			geolocation_city,
			geolocation_state
		)
		SELECT
			geolocation_zip_code_prefix,
			rounded_lat,
			rounded_lng,
			geolocation_city,
			geolocation_state
		FROM GeoDedup
		WHERE rn = 1;

		SET @GeolocationLoaded = @@ROWCOUNT;

		PRINT 'Geolocation Loaded : ' + CAST(@GeolocationLoaded AS VARCHAR(20));
		PRINT '';

        /***********************************************************
            Load Sellers
        ************************************************************/

		PRINT 'Loading silver.sellers...';

        INSERT INTO silver.sellers
        (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        )
        SELECT
            seller_id,
            seller_zip_code_prefix,
            TRIM(seller_city),
            UPPER(TRIM(seller_state))
        FROM bronze.sellers
        WHERE seller_id IS NOT NULL;

        SET @SellersLoaded = @@ROWCOUNT;

		PRINT 'Sellers Loaded : ' + CAST(@SellersLoaded AS VARCHAR(20));
		PRINT '';

        /***********************************************************
            Load Product Category Translation
        ************************************************************/

		PRINT 'Loading silver.product_category_name_translation...';

		INSERT INTO silver.product_category_name_translation
		(
			product_category_name,
			product_category_name_english
		)
		SELECT DISTINCT
			TRIM(p.product_category_name),
			ISNULL(
				TRIM(t.product_category_name_english),
				'[Missing Translation]'
			)
		FROM bronze.products AS p
		LEFT JOIN bronze.product_category_name_translation AS t
			ON TRIM(p.product_category_name) = TRIM(t.product_category_name)
		WHERE
			p.product_category_name IS NOT NULL
			AND TRIM(p.product_category_name) <> '';

        SET @CategoriesLoaded = @@ROWCOUNT;

		PRINT 'Product Category Translation Loaded : ' + CAST(@CategoriesLoaded AS VARCHAR(20));
		PRINT '';

        /***********************************************************
            Load Products
        ************************************************************/

		PRINT 'Loading silver.products...';

        INSERT INTO silver.products
        (
            product_id,
            product_category_name,
            product_name_length,
            product_description_length,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        )
		SELECT
			product_id,

			NULLIF(TRIM(product_category_name), ''),

			TRY_CAST(NULLIF(TRIM(product_name_lenght), '') AS INT),

			TRY_CAST(NULLIF(TRIM(product_description_lenght), '') AS INT),

			TRY_CAST(NULLIF(TRIM(product_photos_qty), '') AS INT),

			TRY_CAST(NULLIF(TRIM(product_weight_g), '') AS DECIMAL(10,2)),

			TRY_CAST(NULLIF(TRIM(product_length_cm), '') AS DECIMAL(10,2)),

			TRY_CAST(NULLIF(TRIM(product_height_cm), '') AS DECIMAL(10,2)),

			TRY_CAST(NULLIF(TRIM(product_width_cm), '') AS DECIMAL(10,2))

		FROM bronze.products
		WHERE product_id IS NOT NULL;

        SET @ProductsLoaded = @@ROWCOUNT;

		PRINT 'Products Loaded : ' + CAST(@ProductsLoaded AS VARCHAR(20));
		PRINT '';

        PRINT '========================================';

		PRINT 'Dimension Load Completed Successfully.';
		PRINT '';

    END TRY

    BEGIN CATCH

        PRINT '========================================';
        PRINT 'Silver Dimension Load Failed';
        PRINT '========================================';
        PRINT 'Error: ' + ERROR_MESSAGE();

        THROW;

    END CATCH

END;
GO