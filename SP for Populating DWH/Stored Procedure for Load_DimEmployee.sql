USE [Sales_WH]
GO

/****** Object:  StoredProcedure [dbo].[Load_DimEmployee]    Script Date: 1/27/2025 9:43:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[Load_DimEmployee]
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
                               WHERE [TableName] = N'Dim_Employee'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

    IF NOT EXISTS (SELECT * FROM Dim_Employee WHERE [_Source Key] = '')
		INSERT INTO [dbo].[Dim_Employee]
				   ([_Source Key]
				   ,[Location Key]
				   ,[Last Name]
				   ,[First Name]
				   ,[Title]
				   ,[Birth Date]
				   ,[Gender]
				   ,[Hire Date]
				   ,[Job Title]
				   ,[Address Line]
				   ,[City]
				   ,[Country]
				   ,[Manager Key]
				   ,[Valid From]
				   ,[Valid To]
				   ,[Lineage Key])
			 VALUES
				   ('', '', 'N/A', 'N/A', 'N/A', '1753-01-01', 'N/A', '1753-01-01', 'N/A', 'N/A', 'N/A', 'N/A', '', '1753-01-01', '9999-12-31', -1)

	-- Update the validity date of modified products in Dim_Product. 
	-- The rows will not be active anymore, because the staging table holds newer versions
    UPDATE emp
    SET emp.[Valid To] = mod_emp.[Valid From]
    FROM 
		Dim_Employee AS emp INNER JOIN 
		Staging_Employee AS mod_emp ON emp.[_Source Key] = mod_emp.[_Source Key]
    WHERE emp.[Valid To] = @EndOfTime

    -- Insert new rows for the modified products
	INSERT Dim_Employee
		   ([_Source Key]
           ,[Location Key]
           ,[Last Name]
           ,[First Name]
           ,[Title]
           ,[Birth Date]
           ,[Gender]
           ,[Hire Date]
           ,[Job Title]
           ,[Address Line]
           ,[City]
           ,[Country]
           ,[Manager Key]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    SELECT [_Source Key]
           ,[Location Key]
           ,[Last Name]
           ,[First Name]
           ,[Title]
           ,[Birth Date]
           ,[Gender]
           ,[Hire Date]
           ,[Job Title]
           ,[Address Line]
           ,[City]
           ,[Country]
           ,[Manager Key]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM Staging_Employee;

    
	-- Update the lineage table for the most current Dim_Product load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE track.Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_Product
	UPDATE track.[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'Dim_Employee';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO


