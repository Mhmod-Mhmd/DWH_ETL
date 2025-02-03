USE [Sales_WH]
GO

CREATE or Alter PROCEDURE [track].[Get-Update_LineageKey]
@LoadType nvarchar(1),
@TableName nvarchar(100),
@LastLoadedDate datetime
AS
BEGIN
   
-- The load for @TableName starts now 
DECLARE @StartLoad datetime = SYSDATETIME();

/* 
A new row is inserted into the Lineage table, with the table name that will be loaded,
the starting date of the load, load type and load status.
Possible values for Type:
- F = Full load
- I = Incremental load

Possible values for Status:
- P = In progress
- E = Error
- S = Success
*/
INSERT INTO [track].[Lineage](
	 [TableName]
	,[StartLoad]
	,[FinishLoad]
	,[Status]
	,[Type]
	,[LastLoadedDate]
	)
VALUES (
	 @TableName
	,@StartLoad
	,NULL
	,'P'
	,@LoadType
	,@LastLoadedDate
	);

-- If we're doing an initial load, remove the date of the most recent load for this table
IF (@LoadType = 'F')
	BEGIN
		UPDATE [track].[IncrementalLoads]
		SET LoadDate = '1753-01-01'
		WHERE TableName = @TableName

		EXEC('TRUNCATE TABLE ' + @TableName)
	END;

-- Select the key of the previously inserted row
SELECT MAX([LineageKey]) AS LineageKey
FROM [track].[Lineage]
WHERE 
	[TableName] = @TableName
	AND [StartLoad] = @StartLoad

RETURN 0;
END;
GO


