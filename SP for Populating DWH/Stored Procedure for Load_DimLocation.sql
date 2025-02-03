USE [Sales_WH]
GO

/****** Object:  StoredProcedure [dbo].[Load_DimLocation]    Script Date: 1/27/2025 9:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[Load_DimLocation]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime =  '9999-12-31';
	DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    -- Get the lineage of the current load of Dim_Product
	DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM track.Lineage
                               WHERE [TableName] = N'Dim_Location'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

	IF NOT EXISTS (SELECT * FROM Dim_Location WHERE [_Source Key] = '')
INSERT INTO [dbo].[Dim_Location]
           ([_Source Key]
           ,[Continent]
           ,[Region]
           ,[Subregion]
           ,[Country Code]
           ,[Country]
           ,[Country Formal Name]
           ,[Country Population]
           ,[Province Code]
           ,[Province]
           ,[Province Population]
           ,[City]
           ,[City Population]
           ,[Address Line 1]
           ,[Address Line 2]
           ,[Postal Code]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
     VALUES
           ('', 'N/A', 'N/A','N/A','N/A','N/A','N/A', -1, 'N/A','N/A', -1, 'N/A', -1, 'N/A', 'N/A', 'N/A', '1753-01-01', '9999-12-31', -1)

	-- Update the validity date of modified products in Dim_Location. 
	-- The rows will not be active anymore, because the staging table holds newer versions
    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
		Dim_Location AS initial INNER JOIN 
		Staging_Location AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime

    -- Insert new rows for the modified products
	INSERT Dim_Location
           ([_Source Key]
           ,[Continent]
           ,[Region]
           ,[Subregion]
           ,[Country Code]
           ,[Country]
           ,[Country Formal Name]
           ,[Country Population]
           ,[Province Code]
           ,[Province]
           ,[Province Population]
           ,[City]
           ,[City Population]
           ,[Address Line 1]
           ,[Address Line 2]
           ,[Postal Code]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    
	SELECT  [_Source Key]
           ,[Continent]
           ,[Region]
           ,[Subregion]
           ,[Country Code]
           ,[Country]
           ,[Country Formal Name]
           ,[Country Population]
           ,[Province Code]
           ,[Province]
           ,[Province Population]
           ,[City]
           ,[City Population]
           ,[Address Line 1]
           ,[Address Line 2]
           ,[Postal Code]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM Staging_Location;

    
	-- Update the lineage table for the most current Dim_Location load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE [track].Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_Product
	UPDATE track.[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'Dim_Location';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO


