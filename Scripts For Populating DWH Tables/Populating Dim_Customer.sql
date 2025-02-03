-- Declaration of the variables needed in this script
DECLARE @LoadType nvarchar(1) = 'F'
DECLARE @TableName nvarchar(100) = 'Dim_Customer';
DECLARE @Prev_LastLoadedDate datetime;
DECLARE @LastLoadedDate datetime; -- New load date
DECLARE @LineageKey int;

DECLARE @lineage TABLE (lineage int)
DECLARE @lastload TABLE (load_date datetime)

SELECT @LastLoadedDate = GETDATE()


INSERT INTO @lineage EXEC [track].[Get-Update_LineageKey] @LoadType, @TableName, @LastLoadedDate
SELECT TOP 1 @LineageKey = lineage FROM @lineage

TRUNCATE TABLE Staging_Product

--STEP 5: Retrieve the date when Dim_customer was last loaded
--STEP 6: Store this date into the @Prev_LastLoadedDate variable
INSERT INTO @lastload EXEC [track].[Get_LastLoadedDate] @TableName
SELECT TOP 1 @Prev_LastLoadedDate = load_date FROM @lastload
SELECT @Prev_LastLoadedDate AS [Date of the previous load]

INSERT INTO [dbo].[Staging_Customer]
	EXEC [Sales_WH].[dbo].[Load_StagingCustomer] @Prev_LastLoadedDate, @LastLoadedDate

-- Take a look what the staging table contains 
SELECT * FROM Staging_Customer

--STEP 8: Transfer information from the staging table to the actual dimension table: Dim_customer
EXEC [dbo].[load_DimCustomer]

SELECT * FROM Dim_Customer
