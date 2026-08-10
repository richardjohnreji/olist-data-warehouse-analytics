/*
===============================================================================
Stored Procedure: gold.usp_Load_Calendar
===============================================================================
Purpose:
    Incrementally loads the Gold Calendar table.

Description:
    - Determines the required calendar range from Silver Orders.
    - Applies a configurable buffer before and after the source data.
    - Inserts only missing calendar dates.
    - Preserves existing calendar records.

Notes:
    • Incremental Load
    • Idempotent
    • Enterprise-style Reference Data Loading
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.usp_Load_Calendar
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

	--------------------------------------------------------
	-- Configuration
	--------------------------------------------------------

	DECLARE @BufferYears TINYINT = 1;

	--------------------------------------------------------
	-- Source Date Range
	--------------------------------------------------------

	DECLARE @SourceMinDate DATE;
	DECLARE @SourceMaxDate DATE;

	--------------------------------------------------------
	-- Required Calendar Range
	--------------------------------------------------------

	DECLARE @RequiredMinDate DATE;
	DECLARE @RequiredMaxDate DATE;

	--------------------------------------------------------
	-- Existing Calendar Range
	--------------------------------------------------------

	DECLARE @CurrentMinDate DATE;
	DECLARE @CurrentMaxDate DATE;

	--------------------------------------------------------
	-- Determine Source Date Range
	--------------------------------------------------------

	SELECT
		@SourceMinDate = MIN(CAST(order_purchase_timestamp AS DATE)),
		@SourceMaxDate = MAX(CAST(order_purchase_timestamp AS DATE))
	FROM silver.orders;

	IF @SourceMinDate IS NULL
	BEGIN
		PRINT 'No orders found in silver.orders.';
		RETURN;
	END;

	--------------------------------------------------------
	-- Apply Calendar Buffer
	--------------------------------------------------------

	SET @RequiredMinDate =
		DATEADD(YEAR,-@BufferYears,@SourceMinDate);

	SET @RequiredMaxDate =
		DATEADD(YEAR,@BufferYears,@SourceMaxDate);

	--------------------------------------------------------
	-- Determine Existing Calendar Range
	--------------------------------------------------------

	SELECT

		@CurrentMinDate = MIN(calendar_date),

		@CurrentMaxDate = MAX(calendar_date)

	FROM gold.calendar;

	PRINT '=========================================';
	PRINT 'Loading Gold Calendar';
	PRINT '=========================================';

	PRINT 'Source Date Range: '
		+ CONVERT(VARCHAR(10), @SourceMinDate, 120)
		+ ' to '
		+ CONVERT(VARCHAR(10), @SourceMaxDate, 120);

	PRINT 'Required Calendar Range: '
		+ CONVERT(VARCHAR(10), @RequiredMinDate, 120)
		+ ' to '
		+ CONVERT(VARCHAR(10), @RequiredMaxDate, 120);

	;WITH CalendarCTE AS
	(
		SELECT
			@RequiredMinDate AS calendar_date

		UNION ALL

		SELECT
			DATEADD(DAY,1,calendar_date)

		FROM CalendarCTE

		WHERE calendar_date < @RequiredMaxDate
	)

	--------------------------------------------------------
	-- Insert Missing Calendar Dates
	--------------------------------------------------------

	INSERT INTO gold.calendar
	(
		calendar_date,
		calendar_year,
		calendar_quarter,
		calendar_month,
		month_name,
		day_of_month,
		day_of_week,
		weekday_name,
		is_weekend
	)

	SELECT

		c.calendar_date,

		YEAR(c.calendar_date),

		DATEPART(QUARTER, c.calendar_date),

		MONTH(c.calendar_date),

		DATENAME(MONTH, c.calendar_date),

		DAY(c.calendar_date),

		DATEPART(WEEKDAY, c.calendar_date),

		DATENAME(WEEKDAY, c.calendar_date),

		CASE
			WHEN DATENAME(WEEKDAY, c.calendar_date)
					IN ('Saturday','Sunday')
			THEN 1
			ELSE 0
		END

	FROM CalendarCTE c

	WHERE NOT EXISTS
	(
		SELECT 1
		FROM gold.calendar gc
		WHERE gc.calendar_date = c.calendar_date
	)


	OPTION (MAXRECURSION 0);
	
	DECLARE @RowsInserted INT = @@ROWCOUNT;

	PRINT 'Calendar Dates Inserted: ' + CAST(@RowsInserted AS VARCHAR(20));

	PRINT 'Gold Calendar Load Completed Successfully.';

	END TRY

	BEGIN CATCH

	PRINT 'Error Loading Gold Calendar';

	PRINT ERROR_MESSAGE();

	THROW;

	END CATCH

END
