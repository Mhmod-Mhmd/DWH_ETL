USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
create or Alter PROCEDURE [dbo].[Load_StagingPaymentType]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	 'HSD|' + CONVERT(NVARCHAR, pay.[PaymentTypeID])				AS [_SourceKey],
	ISNULL(pay.[PaymentTypeName], 'N/A')                     		AS [Payment Type Name],
	CONVERT(datetime, ISNULL(pay.[ModifiedDate], '1753-01-01'))		AS [ValidFrom],
	CONVERT(datetime, '9999-12-31')									AS [ValidTo]
FROM	
	[Sales_DB].[dbo].[PaymentTypes] pay

WHERE 
	([pay].ModifiedDate > @LastLoadDate AND [pay].ModifiedDate <= @NewLoadDate) 

    RETURN 0;
END;
GO


