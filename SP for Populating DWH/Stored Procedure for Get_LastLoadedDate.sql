USE [Sales_WH]
GO

/****** Object:  StoredProcedure [int].[Get_LastLoadedDate]    Script Date: 1/27/2025 9:54:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [track].[Get_LastLoadedDate]
@TableName nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	-- If the procedure is executed with a wrong table name, throw an error.
	IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE name = @TableName AND Type = N'U')
	BEGIN
        PRINT N'The table does not exist in the data warehouse.';
        THROW 51000, N'The table does not exist in the data warehouse.', 1;
        RETURN -1;
	END
	
    -- If the table exists, but was never loaded before, there won't be a record for it in the table
	-- A record is created for the @TableName, with the minimum possible date in the LoadDate column
	IF NOT EXISTS (SELECT 1 FROM [track].[IncrementalLoads] WHERE TableName = @TableName)
		INSERT INTO [track].[IncrementalLoads]
		SELECT @TableName, '1753-01-01'

    -- Select the LoadDate for the @TableName
	SELECT 
		[LoadDate] AS [LoadDate]
    FROM [track].[IncrementalLoads]
    WHERE 
		[TableName] = @TableName;



    RETURN 0;
END;
GO


