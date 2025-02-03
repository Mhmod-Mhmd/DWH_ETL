USE [Sales_WH]
GO


CREATE or alter  PROCEDURE [dbo].[Test_LoadFact]
@LoadType nvarchar(1) = 'F',
@TableName nvarchar(100) = 'Fact_Sales',
@LastLoadedDate datetime
AS
BEGIN
-- Declaration of the variables needed in this script
DECLARE @Prev_LastLoadedDate datetime;
DECLARE @LineageKey int;

DECLARE @lineage TABLE (lineage int)
DECLARE @lastload TABLE (load_date datetime)

--STEP 1: If it's an initial load, change the last loaded date from the IncrementalLoads table to be something in the past
IF (@LoadType = 'F')
	UPDATE track.[IncrementalLoads]
	SET LoadDate = '1753-01-01'
	WHERE TableName = @TableName

--STEP 2: Insert a new row into the lineage table, to keep track of the new Dim_Product load that just started
--STEP 3: Store the key of the new row in the @LineageKey variable, for future usage
INSERT INTO @lineage EXEC [track].[Get_LineageKey] @LoadType, @TableName, @LastLoadedDate
SELECT TOP 1 @LineageKey = lineage FROM @lineage

-- Take a look at the current lineage number
SELECT @LineageKey AS [Current lineage]


TRUNCATE TABLE Staging_Sales

INSERT INTO @lastload EXEC [track].[Get_LastLoadedDate] @TableName
SELECT TOP 1 @Prev_LastLoadedDate = load_date FROM @lastload
SELECT @Prev_LastLoadedDate AS [Date of the previous load]


--STEP 7: Insert into the staging table new products or products that were modified after the last Dim_Product load finished 
	INSERT INTO [dbo].[Staging_Sales]
		([_SourceOrderDateKey],
		[_SourceDeliveryDateKey],
		[_SourceOrder],
		[_SourceOrderLine],
		[_SourceCustomerKey],
		[_SourceEmployeeKey],
		[_SourceProductKey],
		[_SourcePaymentTypeKey],
		[_SourceDeliveryCountryKey],
		[_SourceDeliveryProvinceKey],
		[_SourceDeliveryCityKey],
		[_SourceDeliveryAddressKey],
		[_SourceDeliveryLocationKey],
		[_SourcePromotionKey],
		[Description],
		[Package],
		[Quantity],
		[Unit Price],
		[VAT Rate],
		[Total Excluding VAT],
		[VAT Amount],
		[Total Including VAT],
		[ModifiedDate]
		)
	EXEC [Sales_WH].[dbo].[Load_StagingSales] @Prev_LastLoadedDate, @LastLoadedDate


TRUNCATE TABLE Fact_Sales

-- Populate the fact table
EXEC [dbo].[Load_FactSales]

END
GO


