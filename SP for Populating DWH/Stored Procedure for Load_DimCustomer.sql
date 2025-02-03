USE [Sales_WH]
GO

/****** Object:  StoredProcedure [dbo].[Load_DimCustomer]    Script Date: 1/27/2025 9:45:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[Load_DimCustomer]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime =  '9999-12-31';
	DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    -- Get the lineage of the current load of Dim_Customer
	DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM track.Lineage
                               WHERE [TableName] = N'Dim_Customer'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

	-- Update the validity date of modified customers in Dim_Customer. 
	-- The rows will not be active anymore, because the staging table holds newer versions
    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
		Dim_Customer AS initial INNER JOIN 
		Staging_Customer AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime

    IF NOT EXISTS (SELECT 1 FROM Dim_Customer WHERE [_Source Key] = '')
		INSERT Dim_Customer
           ([_Source Key]
           ,[First Name]
           ,[Last Name]
           ,[Title]
           ,[Delivery Location Key]
           ,[Billing Location Key]
           ,[Phone Number]
           ,[Email]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
	VALUES ('', 'N/A', 'N/A', 'N/A', '', '', 'N/A', 'N/A', '1753-01-01', '9999-12-31', -1)
	
	-- Insert new rows for the modified Customers
	INSERT Dim_Customer
           ([_Source Key]
           ,[First Name]
           ,[Last Name]
           ,[Title]
           ,[Delivery Location Key]
           ,[Billing Location Key]
           ,[Phone Number]
           ,[Email]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    
	SELECT  [_Source Key]
           ,[First Name]
           ,[Last Name]
           ,[Title]
           ,[Delivery Location Key]
           ,[Billing Location Key]
           ,[Phone Number]
           ,[Email]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM Staging_Customer;

    
	-- Update the lineage table for the most current Dim_Customer load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE track.Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_Customer
	UPDATE [track].[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'Dim_Customer';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO


