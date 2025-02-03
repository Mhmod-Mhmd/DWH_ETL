USE [Sales_WH]
GO



-- Create the procedure that populates the Fact_Sales table
CREATE   PROCEDURE [dbo].[Load_FactSales]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @EndOfTime datetime =  '9999-12-31';
	DECLARE @LastDateLoaded datetime;


    BEGIN TRAN;

    -- Select the lineage, for logging purposes. This will be used in the ETL load
	DECLARE @LineageKey int = ISNULL((SELECT TOP(1) [LineageKey]
                               FROM track.Lineage
                               WHERE [TableName] = N'Fact_Sales'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC), -1);


    -- Update the surrogate key columns in the staging table
    UPDATE s
	SET  s.[Customer Key] = COALESCE((
								SELECT TOP (1) c.[Customer Key]
								FROM Dim_Customer AS c
								WHERE REPLACE(c.[_Source Key], 'HSD|', '') = s.[_SourceCustomerKey]
									--AND c.[Valid To] = '9999-12-31'
									AND s.[ModifiedDate] >= c.[Valid From]
									AND s.[ModifiedDate] < c.[Valid To]
								ORDER BY c.[Valid From]
							), (
								SELECT TOP (1) c.[Customer Key]
								FROM Dim_Customer AS c
								WHERE c.[_Source Key] = ''
							), 0),

		s.[Employee Key] = COALESCE((
								SELECT TOP(1) e.[Employee Key]
                                FROM Dim_Employee AS e
                                WHERE REPLACE(e.[_Source Key], 'HSD|', '') = s.[_SourceEmployeeKey]
                               	--AND e.[Valid To] = '9999-12-31'
							     AND s.[ModifiedDate] >= e.[Valid From]
								 AND s.[ModifiedDate] < e.[Valid To]
								ORDER BY e.[Valid From]
								), (
								SELECT TOP (1) e.[Employee Key]
								FROM Dim_Employee AS e
								WHERE e.[_Source Key] = ''
							), 0),
		s.[Product Key] = COALESCE((
								SELECT TOP(1) p.[Product Key]
                                FROM Dim_Product AS p
                                WHERE REPLACE(p.[_Source Key], 'HSD|', '') = s.[_SourceProductKey]
                                    --AND p.[Valid To] = '9999-12-31'
									AND s.[ModifiedDate] >= p.[Valid From]
                                    AND s.[ModifiedDate] < p.[Valid To]
								ORDER BY p.[Valid From]
								), (
								SELECT TOP (1) p.[Product Key]
								FROM Dim_Product AS p
								WHERE p.[_Source Key] = ''
							), 0),
		s.[Payment Type Key] = COALESCE((
								SELECT TOP(1) pm.[Payment Type Key]
                                FROM Dim_PaymentType AS pm
                                WHERE REPLACE(pm.[_Source Key], 'HSD|', '') = s.[_SourcePaymentTypeKey]
                                    --AND pm.[Valid To] = '9999-12-31'
									AND s.[ModifiedDate] >= pm.[Valid From]
                                    AND s.[ModifiedDate] < pm.[Valid To]
								ORDER BY pm.[Valid From]
								), (
								SELECT TOP (1) pm.[Payment Type Key]
								FROM Dim_PaymentType AS pm
								WHERE pm.[_Source Key] = ''
							), 0),

		s.[Delivery Location Key] = COALESCE((
								SELECT TOP(1) l.[Location Key]
                                FROM Dim_Location AS l
                                WHERE REPLACE(l.[_Source Key], 'HSD|', '') = s.[_SourceDeliveryLocationKey]
                                    --AND l.[Valid To] = '9999-12-31'
									AND s.[ModifiedDate] >= l.[Valid From]
                                    AND s.[ModifiedDate] < l.[Valid To]
								ORDER BY l.[Valid From]
								), (
								SELECT TOP (1) l.[Location Key]
								FROM Dim_Location AS l
								WHERE l.[_Source Key] = ''
							), 0),
		s.[Promotion Key] = COALESCE((
							SELECT TOP(1) p.[Promotion Key]
                            FROM Dim_Promotion AS p
                            WHERE REPLACE(p.[_Source Key], 'HSD|', '') = s.[_SourcePromotionKey]
                                 --AND p.[Valid To] = '9999-12-31'
								 AND s.[ModifiedDate] >= p.[Valid From]
                                 AND s.[ModifiedDate] < p.[Valid To]
							ORDER BY p.[Valid From]
							), (
							SELECT TOP (1) p.[Promotion Key]
							FROM Dim_Promotion AS p
							WHERE p.[_Source Key] = ''
							), 0),
		s.[Order Date Key] = COALESCE((SELECT TOP(1) d.[Date Key]
                                           FROM Dim_Date AS d
                                           WHERE d.[Date] = s.[_SourceOrderDateKey]
									       ), 0),
		s.[Delivery Date Key] = COALESCE((SELECT TOP(1) d.[Date Key]
                                           FROM Dim_Date AS d
                                           WHERE d.[Date] = s.[_SourceDeliveryDateKey]
									       ), 0)
    FROM [dbo].[Staging_Sales] AS s;

    -- Delete data from the fact table that is present now in the staging table 
    DELETE s
    FROM [dbo].[Fact_Sales] AS s
    WHERE s._SourceOrder IN (SELECT [_SourceOrder] FROM [dbo].[Staging_Sales]);

-- Perform a simple insert from staging to the fact
INSERT INTO [dbo].[Fact_Sales]
           ([Customer Key]
           ,[Employee Key]
           ,[Product Key]
           ,[Payment Type Key]
           ,[Order Date Key]
           ,[Delivery Date Key]
           ,[Delivery Location Key]
           ,[Promotion Key]
           ,[Description]
           ,[Package]
           ,[Quantity]
           ,[Unit Price]
           ,[VAT Rate]
           ,[Total Excluding VAT]
           ,[VAT Amount]
           ,[Total Including VAT]
           ,[_SourceOrder]
           ,[_SourceOrderLine]
           ,[Lineage Key])
SELECT 
			[Customer Key]
           ,[Employee Key]
           ,[Product Key]
           ,[Payment Type Key]
           ,[Order Date Key]
           ,[Delivery Date Key]
           ,[Delivery Location Key]
           ,[Promotion Key]
           ,[Description]
           ,[Package]
           ,[Quantity]
           ,[Unit Price]
           ,[VAT Rate]
           ,[Total Excluding VAT]
           ,[VAT Amount]
           ,[Total Including VAT]
           ,[_SourceOrder]
           ,[_SourceOrderLine]
		   ,@LineageKey
	FROM [dbo].[Staging_Sales]

	-- Update the lineage table for the most current Dim_Customer load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE [track].Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_Customer
	UPDATE [track].[IncrementalLoads]
        SET [LoadDate] = ISNULL(@LastDateLoaded, GETDATE())
    WHERE [TableName] = N'Fact_Sales';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO


