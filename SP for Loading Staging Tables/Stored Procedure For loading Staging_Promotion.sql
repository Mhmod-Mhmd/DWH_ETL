USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
create or Alter  PROCEDURE [dbo].[Load_StagingPromotion]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	 'HSD|' + CONVERT(NVARCHAR, pro.[PromotionID])					AS [_SourceKey],
	ISNULL(pro.[DealDescription], 'N/A')                    		AS [Deal Description],
	CONVERT(date,ISNULL(pro.[StartDate], '1753-01-01'))				AS [Start Date],
	CONVERT(date,ISNULL(pro.[EndDate], '1753-01-01'))				AS [End Date],
	CONVERT(decimal(18,2), ISNULL(pro.[DiscountAmount], 0))			AS [Discount Amount], 
	CONVERT(decimal(18,3), ISNULL(pro.[DiscountPercentage], 0))		AS [Discount Percentage], 
	CONVERT(datetime, ISNULL(pro.[ModifiedDate], '1753-01-01'))		AS [Promotion Modified Date],
	CONVERT(datetime, ISNULL(pro.[ModifiedDate], '1753-01-01'))		AS [ValidFrom],
	CONVERT(datetime, '9999-12-31')									AS [ValidTo]
FROM	
	[Sales_DB].[dbo].[Promotions] pro

WHERE 
	([pro].ModifiedDate > @LastLoadDate AND [pro].ModifiedDate <= @NewLoadDate) 

    RETURN 0;
END;
GO


