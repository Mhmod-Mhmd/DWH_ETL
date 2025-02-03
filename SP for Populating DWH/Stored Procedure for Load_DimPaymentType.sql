USE [Sales_WH]
GO

/****** Object:  StoredProcedure [dbo].[Load_DimPaymentType]    Script Date: 1/27/2025 9:47:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE    PROCEDURE [dbo].[Load_DimPaymentType]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime =  '9999-12-31';
	DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    -- Get the lineage of the current load of Dim_PaymentType
	DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM track.Lineage
                               WHERE [TableName] = N'Dim_PaymentType'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

	    IF NOT EXISTS (SELECT * FROM Dim_PaymentType WHERE [_Source Key] = '')
			INSERT INTO [dbo].[Dim_PaymentType]
				   ([_Source Key]
				   ,[Payment Type Name]
				   ,[Valid From]
				   ,[Valid To]
				   ,[Lineage Key])
			 VALUES
				   ('', 'N/A', '1753-01-01', '9999-12-31', -1)

	
	-- Update the validity date of modified PaymentTypes in Dim_PaymentType. 
	-- The rows will not be active anymore, because the staging table holds newer versions
    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
		Dim_PaymentType AS initial INNER JOIN 
		Staging_PaymentType AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime

    -- Insert new rows for the modified PaymentTypes
	INSERT Dim_PaymentType
           ([_Source Key]
           ,[Payment Type Name]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    
	SELECT  [_Source Key]
           ,[Payment Type Name]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM Staging_PaymentType;

    
	-- Update the lineage table for the most current Dim_PaymentType load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE [track].Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_PaymentType
	UPDATE [track].[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'Dim_PaymentType';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO


