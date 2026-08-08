/*
===============================================================================
Procedure : silver.usp_Load_Silver_Facts

Purpose:
    Loads transactional tables from Bronze to Silver.

Tables Loaded:
    1. orders
    2. order_items
    3. order_payments
    4. order_reviews

Load Strategy:
    Full Refresh
===============================================================================
*/

USE OlistDW;
GO

CREATE OR ALTER PROCEDURE silver.usp_Load_Silver_Facts
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	------------------------------------------------------------
    -- Step 1: Row Count Variables
    ------------------------------------------------------------

	DECLARE @OrdersLoaded INT = 0;
	DECLARE @OrderItemsLoaded INT = 0;
	DECLARE @PaymentsLoaded INT = 0;
	DECLARE @ReviewsLoaded INT = 0;

    BEGIN TRY

        BEGIN TRANSACTION;

		------------------------------------------------------------
		-- Step 2: Load Orders
		------------------------------------------------------------

        PRINT 'Loading silver.orders...';

        INSERT INTO silver.orders
        (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
        SELECT
            TRIM(b.order_id),
            TRIM(b.customer_id),
            LOWER(TRIM(b.order_status)),

            TRY_CONVERT(datetime2, TRIM(b.order_purchase_timestamp)),
            TRY_CONVERT(datetime2, TRIM(b.order_approved_at)),
            TRY_CONVERT(datetime2, TRIM(b.order_delivered_carrier_date)),
            TRY_CONVERT(datetime2, TRIM(b.order_delivered_customer_date)),
            TRY_CONVERT(datetime2, TRIM(b.order_estimated_delivery_date))

        FROM bronze.orders AS b
        INNER JOIN silver.customers AS c
            ON TRIM(b.customer_id) = c.customer_id;
		
		SET @OrdersLoaded = @@ROWCOUNT;
		PRINT 'Orders Loaded : ' + CAST(@OrdersLoaded AS VARCHAR(20));
		PRINT '';

		------------------------------------------------------------
		--Step 3: Load Order Items
		------------------------------------------------------------

		PRINT 'Loading silver.order_items...';

		INSERT INTO silver.order_items
		(
			order_id,
			order_item_id,
			product_id,
			seller_id,
			shipping_limit_date,
			price,
			freight_value
		)
		SELECT
			TRIM(oi.order_id),
			TRY_CONVERT(INT, TRIM(oi.order_item_id)),
			TRIM(oi.product_id),
			TRIM(oi.seller_id),
			TRY_CONVERT(datetime2, TRIM(oi.shipping_limit_date)),
			TRY_CONVERT(decimal(10,2), TRIM(oi.price)),
			TRY_CONVERT(decimal(10,2), TRIM(oi.freight_value))
		FROM bronze.order_items AS oi
		INNER JOIN silver.orders   AS o ON TRIM(oi.order_id)   = o.order_id
		INNER JOIN silver.products AS p ON TRIM(oi.product_id) = p.product_id
		INNER JOIN silver.sellers  AS s ON TRIM(oi.seller_id)  = s.seller_id;

		SET @OrderItemsLoaded = @@ROWCOUNT;
		PRINT 'Order Items Loaded : ' + CAST(@OrderItemsLoaded AS VARCHAR(20));
		PRINT '';

		------------------------------------------------------------
		--Step 4: Load Order Payments
		------------------------------------------------------------

		PRINT 'Loading silver.order_payments...';

		INSERT INTO silver.order_payments
		(
			order_id,
			payment_sequential,
			payment_type,
			payment_installments,
			payment_value
		)
		SELECT
			TRIM(op.order_id),
			TRY_CONVERT(INT, TRIM(op.payment_sequential)),
			LOWER(TRIM(op.payment_type)),
			TRY_CONVERT(INT, TRIM(op.payment_installments)),
			TRY_CONVERT(DECIMAL(10,2), TRIM(op.payment_value))
		FROM bronze.order_payments AS op
		INNER JOIN silver.orders AS o
			ON TRIM(op.order_id) = o.order_id;
		
		SET @PaymentsLoaded = @@ROWCOUNT;
		PRINT 'Order Payments Loaded : ' + CAST(@PaymentsLoaded  AS VARCHAR(20));
		PRINT '';

		------------------------------------------------------------
		-- Step 5: Load Order Reviews
		------------------------------------------------------------

		PRINT 'Loading silver.order_reviews...';

		INSERT INTO silver.order_reviews
		(
			review_id,
			order_id,
			review_score,
			review_comment_title,
			review_comment_message,
			review_creation_date,
			review_answer_timestamp
		)
		SELECT
			TRIM(r.review_id),
			TRIM(r.order_id),
			TRY_CONVERT(INT, TRIM(r.review_score)),
			NULLIF(TRIM(r.review_comment_title), ''),
			NULLIF(TRIM(r.review_comment_message), ''),
			TRY_CONVERT(datetime2, TRIM(r.review_creation_date)),
			TRY_CONVERT(datetime2, TRIM(r.review_answer_timestamp))
		FROM bronze.order_reviews AS r
		INNER JOIN silver.orders AS o
			ON TRIM(r.order_id) = o.order_id;
		
		SET @ReviewsLoaded = @@ROWCOUNT;
		PRINT 'Order Reviews Loaded : ' + CAST(@ReviewsLoaded AS VARCHAR(20));
		PRINT '';

	    COMMIT TRANSACTION;

        PRINT 'Silver Fact Load Completed Successfully.';
		PRINT '';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH

END;
GO