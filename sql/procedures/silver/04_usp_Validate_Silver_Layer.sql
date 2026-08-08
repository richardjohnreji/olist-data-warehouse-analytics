/******************************************************************************
Project     : Olist Data Warehouse & Analytics
File        : usp_Validate_Silver_Layer.sql
Layer       : Silver
Database    : OlistDW

Description :
    Performs quality assurance checks on the Silver layer after
    the ETL process has completed.

Validation Includes:
    • Row Count Validation
    • Referential Integrity Validation
    • Duplicate Key Validation
    • NULL Validation
    • Business Rule Validation

Purpose:
    Ensures the Silver layer is complete, consistent,
    and ready for downstream Gold layer transformations.

Execution:
    Run after:
        silver.usp_Load_Silver_All

Expected Result:
    Overall Status : PASS

Use:
	EXEC silver.usp_Validate_Silver_Layer
******************************************************************************/

USE OlistDW;
GO

CREATE OR ALTER PROCEDURE silver.usp_Validate_Silver_Layer
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    --------------------------------------------------------
    -- Variables
    --------------------------------------------------------
    DECLARE @OverallStatus VARCHAR(10) = 'PASS';
	DECLARE @BronzeCount INT;
	DECLARE @SilverCount INT;
	DECLARE @Status VARCHAR(10);

    PRINT '=========================================';
    PRINT 'Silver Layer Validation Report';
    PRINT '=========================================';
    PRINT '';

    --------------------------------------------------------
    -- 1. Row Count Validation
    --------------------------------------------------------

	PRINT 'Row Count Validation';
	PRINT '------------------------------';

	--------------------------------------------------------
	-- Customers
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.customers;
	SELECT @SilverCount = COUNT(*) FROM silver.customers;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'customers';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Geolocation
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT
				ROW_NUMBER() OVER
				(
					PARTITION BY
						geolocation_zip_code_prefix,
						ROUND(CAST(geolocation_lat AS DECIMAL(18,15)),6),
						ROUND(CAST(geolocation_lng AS DECIMAL(18,15)),6)
					ORDER BY
						TRIM(geolocation_city)
				) AS rn
			FROM bronze.geolocation
		) AS x
		WHERE rn = 1
	);

	SELECT @SilverCount = COUNT(*)
	FROM silver.geolocation;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'geolocation';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Sellers
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.sellers;
	SELECT @SilverCount = COUNT(*) FROM silver.sellers;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'sellers';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Product Categories
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(DISTINCT product_category_name)
		FROM bronze.products
		WHERE product_category_name IS NOT NULL
		  AND TRIM(product_category_name) <> ''
	);

	SELECT @SilverCount =
	(
		SELECT COUNT(*)
		FROM silver.product_category_name_translation
	);

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'product categories';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Products
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.products;
	SELECT @SilverCount = COUNT(*) FROM silver.products;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'products';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Orders
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.orders;
	SELECT @SilverCount = COUNT(*) FROM silver.orders;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'orders';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.order_items;
	SELECT @SilverCount = COUNT(*) FROM silver.order_items;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_items';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Payments
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.order_payments;
	SELECT @SilverCount = COUNT(*) FROM silver.order_payments;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_payments';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Reviews
	--------------------------------------------------------

	SELECT @BronzeCount = COUNT(*) FROM bronze.order_reviews;
	SELECT @SilverCount = COUNT(*) FROM silver.order_reviews;

	SET @Status = CASE
					WHEN @BronzeCount = @SilverCount THEN 'PASS'
					ELSE 'FAIL'
				  END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_reviews';
	PRINT 'Bronze: ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Silver: ' + CAST(@SilverCount AS VARCHAR(20));
	PRINT 'Status: ' + @Status;
	PRINT '';

    --------------------------------------------------------
    -- 2. Referential Integrity
    --------------------------------------------------------

    PRINT 'Referential Integrity Validation';
	PRINT '--------------------------------';

	--------------------------------------------------------
	-- Orders -> Customers
	--------------------------------------------------------
	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.orders o
		LEFT JOIN silver.customers c
			ON o.customer_id = c.customer_id
		WHERE c.customer_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'orders -> customers';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items -> Orders
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items oi
		LEFT JOIN silver.orders o
			ON oi.order_id = o.order_id
		WHERE o.order_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_items -> orders';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items -> Products
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items oi
		LEFT JOIN silver.products p
			ON oi.product_id = p.product_id
		WHERE p.product_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_items -> products';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items -> Sellers
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items oi
		LEFT JOIN silver.sellers s
			ON oi.seller_id = s.seller_id
		WHERE s.seller_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_items -> sellers';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Payments -> Orders
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_payments op
		LEFT JOIN silver.orders o
			ON op.order_id = o.order_id
		WHERE o.order_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_payments -> orders';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Reviews -> Orders
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_reviews r
		LEFT JOIN silver.orders o
			ON r.order_id = o.order_id
		WHERE o.order_id IS NULL
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'order_reviews -> orders';
	PRINT 'Orphan Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- 3. Duplicate Key Validation
	--------------------------------------------------------

	PRINT 'Duplicate Key Validation';
	PRINT '------------------------';

	--------------------------------------------------------
	-- Customers
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT customer_id
			FROM silver.customers
			GROUP BY customer_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'customers';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Geolocation
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT
				geolocation_zip_code_prefix,
				geolocation_lat,
				geolocation_lng
			FROM silver.geolocation
			GROUP BY
				geolocation_zip_code_prefix,
				geolocation_lat,
				geolocation_lng
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'geolocation';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Sellers
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT seller_id
			FROM silver.sellers
			GROUP BY seller_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'sellers';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Product Categories
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT product_category_name
			FROM silver.product_category_name_translation
			GROUP BY product_category_name
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'product categories';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Products
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT product_id
			FROM silver.products
			GROUP BY product_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'products';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Orders
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT order_id
			FROM silver.orders
			GROUP BY order_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'orders';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT order_id, order_item_id
			FROM silver.order_items
			GROUP BY order_id, order_item_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'order_items';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Payments
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT order_id, payment_sequential
			FROM silver.order_payments
			GROUP BY order_id, payment_sequential
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'order_payments';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Reviews
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM
		(
			SELECT review_id, order_id
			FROM silver.order_reviews
			GROUP BY review_id, order_id
			HAVING COUNT(*) > 1
		) d
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;

	IF @Status='FAIL'
		SET @OverallStatus='FAIL';

	PRINT 'order_reviews';
	PRINT 'Duplicate Keys : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status         : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- 4. NULL Validation
	--------------------------------------------------------

	PRINT 'NULL Validation';
	PRINT '---------------';

	--------------------------------------------------------
	-- Customers
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.customers
		WHERE customer_id IS NULL
		   OR customer_unique_id IS NULL
		   OR customer_zip_code_prefix IS NULL
		   OR customer_city IS NULL
		   OR customer_state IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'customers';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Geolocation
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.geolocation
		WHERE geolocation_zip_code_prefix IS NULL
		   OR geolocation_lat IS NULL
		   OR geolocation_lng IS NULL
		   OR geolocation_city IS NULL
		   OR geolocation_state IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'geolocation';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Sellers
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.sellers
		WHERE seller_id IS NULL
		   OR seller_zip_code_prefix IS NULL
		   OR seller_city IS NULL
		   OR seller_state IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'sellers';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Product Categories
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.product_category_name_translation
		WHERE product_category_name IS NULL
		   OR product_category_name_english IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'product categories';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Products
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.products
		WHERE product_id IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'products';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Orders
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.orders
		WHERE order_id IS NULL
		   OR customer_id IS NULL
		   OR order_status IS NULL
		   OR order_purchase_timestamp IS NULL
		   OR order_estimated_delivery_date IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'orders';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Items
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items
		WHERE order_id IS NULL
		   OR order_item_id IS NULL
		   OR product_id IS NULL
		   OR seller_id IS NULL
		   OR shipping_limit_date IS NULL
		   OR price IS NULL
		   OR freight_value IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'order_items';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Payments
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_payments
		WHERE order_id IS NULL
		   OR payment_sequential IS NULL
		   OR payment_type IS NULL
		   OR payment_installments IS NULL
		   OR payment_value IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'order_payments';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Reviews
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_reviews
		WHERE review_id IS NULL
		   OR order_id IS NULL
		   OR review_score IS NULL
		   OR review_creation_date IS NULL
		   OR review_answer_timestamp IS NULL
	);

	SET @Status = CASE WHEN @BronzeCount = 0 THEN 'PASS' ELSE 'FAIL' END;
	IF @Status='FAIL' SET @OverallStatus='FAIL';

	PRINT 'order_reviews';
	PRINT 'NULL Values : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status      : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- 5. Business Rule Validation
	--------------------------------------------------------

	PRINT 'Business Rule Validation';
	PRINT '------------------------------';

	--------------------------------------------------------
	-- Review Score (1-5)
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_reviews
		WHERE review_score NOT BETWEEN 1 AND 5
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Review Score Range';
	PRINT 'Invalid Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status       : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Payment Installments (0-24)
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_payments
		WHERE payment_installments NOT BETWEEN 0 AND 24
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Payment Installments';
	PRINT 'Invalid Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status       : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Payment Value
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_payments
		WHERE payment_value < 0
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Payment Value';
	PRINT 'Negative Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status        : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Product Price
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items
		WHERE price < 0
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Product Price';
	PRINT 'Negative Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status        : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Freight Value
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items
		WHERE freight_value < 0
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Freight Value';
	PRINT 'Negative Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status        : ' + @Status;
	PRINT '';

	--------------------------------------------------------
	-- Order Item ID
	--------------------------------------------------------

	SELECT @BronzeCount =
	(
		SELECT COUNT(*)
		FROM silver.order_items
		WHERE order_item_id < 1
	);

	SET @Status =
	CASE
		WHEN @BronzeCount = 0 THEN 'PASS'
		ELSE 'FAIL'
	END;

	IF @Status = 'FAIL'
		SET @OverallStatus = 'FAIL';

	PRINT 'Order Item ID';
	PRINT 'Invalid Rows : ' + CAST(@BronzeCount AS VARCHAR(20));
	PRINT 'Status       : ' + @Status;
	PRINT '';

    --------------------------------------------------------
    -- Final Summary
    --------------------------------------------------------

    PRINT '-----------------------------------------';
    PRINT 'Overall Status: ' + @OverallStatus;
    PRINT '=========================================';
END;
GO