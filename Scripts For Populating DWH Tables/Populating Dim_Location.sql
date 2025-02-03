-- Declaration of the variables needed in this script
DECLARE @LoadType nvarchar(1) = 'F'
DECLARE @TableName nvarchar(100) = 'Dim_Location';
DECLARE @Prev_LastLoadedDate datetime;
DECLARE @LastLoadedDate datetime; -- New load date
DECLARE @LineageKey int;

DECLARE @lineage TABLE (lineage int)
DECLARE @lastload TABLE (load_date datetime)

SELECT @LastLoadedDate = GETDATE()


INSERT INTO @lineage EXEC [track].[Get-Update_LineageKey] @LoadType, @TableName, @LastLoadedDate
SELECT TOP 1 @LineageKey = lineage FROM @lineage

TRUNCATE TABLE Staging_Location


INSERT INTO @lastload EXEC [track].[Get_LastLoadedDate] @TableName
SELECT TOP 1 @Prev_LastLoadedDate = load_date FROM @lastload
SELECT @Prev_LastLoadedDate AS [Date of the previous load]

INSERT INTO [dbo].[Staging_Location]
	EXEC [Sales_WH].[dbo].[Load_StagingLocation] @Prev_LastLoadedDate, @LastLoadedDate

SELECT * FROM Staging_Location

EXEC [dbo].[Load_DimLocation]

SELECT * FROM Dim_Location
