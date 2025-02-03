USE [Sales_WH]
GO

/****** Object:  StoredProcedure [dbo].[Test_LoadDimension]    Script Date: 1/27/2025 9:51:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[Test_LoadDimension]
@LoadType nvarchar(1) = 'F',
@TableName nvarchar(100) = 'Dim_Product',
@LastLoadedDate datetime
AS
BEGIN
-- Declaration of the variables needed in this script
DECLARE @Prev_LastLoadedDate datetime;
DECLARE @LineageKey int;

DECLARE @lineage TABLE (lineage int)
DECLARE @lastload TABLE (load_date datetime)

DECLARE @StagingTableName nvarchar(100) = REPLACE(REPLACE(@TableName, 'Dim_', 'Staging_'), 'Fact_', 'Staging_');
DECLARE @StagingSP nvarchar(50) = 'Load_Staging' + REPLACE(REPLACE(@TableName, 'Dim_', ''), 'Fact_', '');
DECLARE @DimSP nvarchar(50) = 'Load_Dim' + REPLACE(REPLACE(@TableName, 'Dim_', ''), 'Fact_', '');

DECLARE @SQL nvarchar(max);

--STEP 1: If it's an initial load, change the last loaded date from the IncrementalLoads table to be something in the past
IF (@LoadType = 'F')
	UPDATE [track].[IncrementalLoads]
	SET LoadDate = '1753-01-01'
	WHERE TableName = @TableName

--STEP 2: Insert a new row into the lineage table, to keep track of the new Dim_Product load that just started
--STEP 3: Store the key of the new row in the @LineageKey variable, for future usage
INSERT INTO @lineage EXEC [int].[Get_LineageKey] @LoadType, @TableName, @LastLoadedDate
SELECT TOP 1 @LineageKey = lineage FROM @lineage

-- Take a look at the current lineage number
SELECT @LineageKey AS [Current lineage]


--STEP 4: Make sure that the Staging_Product table is empty before loading new information in it
SET @SQL = 'TRUNCATE TABLE ' + @StagingTableName
PRINT @SQL
EXEC sp_executesql @SQL


--STEP 5: Retrieve the date when Dim_Product was last loaded
--STEP 6: Store this date into the @Prev_LastLoadedDate variable
INSERT INTO @lastload EXEC [int].[Get_LastLoadedDate] @TableName
SELECT TOP 1 @Prev_LastLoadedDate = load_date FROM @lastload
SELECT @Prev_LastLoadedDate AS [Date of the previous load]


--STEP 7: Insert into the staging table new products or products that were modified after the last Dim_Product load finished 
SET @SQL = 'INSERT INTO ' + @StagingTableName + ' EXEC [HappyScoopers_Demo].[dbo].' + @StagingSP + ' ''' + CONVERT(nvarchar(20), @Prev_LastLoadedDate, 23) + ''',''' + convert(nvarchar(20), @LastLoadedDate, 23) + ''''
PRINT @SQL
EXEC sp_executesql @SQL

-- For an initial load, truncate also the dimension table
SET @SQL = 'TRUNCATE TABLE ' + @TableName
PRINT @SQL
EXEC sp_executesql @SQL


--STEP 8: Transfer information from the staging table to the actual dimension table: Dim_Product
SET @SQL = 'EXEC ' + @DimSP
PRINT @SQL
EXEC sp_executesql @SQL

END
GO


