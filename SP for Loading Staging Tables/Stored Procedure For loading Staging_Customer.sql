USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
create or Alter PROCEDURE [dbo].[Load_StagingCustomer]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	 'HSD|' + CONVERT(NVARCHAR, cus.[CustomerID])						AS [_SourceKey],
	CONVERT(nvarchar(100),ISNULL(cus.[FirstName], 'N/A'))				AS [First Name],
	CONVERT(nvarchar(100),ISNULL(cus.[LastName], 'N/A'))				AS [Last Name],
	CONVERT(nvarchar(200),ISNULL(cus.[FullName], 'N/A'))				AS [Full Name],
	CONVERT(nvarchar(30), ISNULL(cus.[Title], 'N/A'))					AS [Title], 
	CONCAT_WS('|', 'HSD', 
		CONVERT(nvarchar(5), ISNULL(dcou.CountryID, 0)),
		CONVERT(nvarchar(5), ISNULL(dprv.ProvinceID, 0)),
		CONVERT(nvarchar(5), ISNULL(dcit.CityID, 0)), 
		CONVERT(nvarchar(5), ISNULL(dadr.AddressID, 0)))				AS [Delivery Location Key],
	CONCAT_WS('|', 'HSD', 
		CONVERT(nvarchar(5), ISNULL(bcou.CountryID, 0)),
		CONVERT(nvarchar(5), ISNULL(bprv.ProvinceID, 0)),
		CONVERT(nvarchar(5), ISNULL(bcit.CityID, 0)), 
		CONVERT(nvarchar(5), ISNULL(badr.AddressID, 0)))				AS [Billing Location Key],
	CONVERT(nvarchar(24), ISNULL(cus.[PhoneNumber], 'N/A'))				AS [Phone Number], 
	CONVERT(nvarchar(100),ISNULL(cus.[Email], 'N/A'))					AS [Email],
	CONVERT(datetime, ISNULL([cus].ModifiedDate, '1753-01-01'))		    AS [Customer Modified Date],
	CONVERT(datetime, ISNULL([dadr].ModifiedDate, '1753-01-01'))		AS [Delivery Addr Modified Date],
	CONVERT(datetime, ISNULL([badr].ModifiedDate, '1753-01-01'))		AS [Billing Addr Modified Date],
	(SELECT MAX(t) FROM
                             (VALUES
                               ([cus].ModifiedDate)
                             , ([badr].ModifiedDate)
                             , ([dadr].ModifiedDate)
                             ) AS [maxModifiedDate](t)
                           )											AS [Valid From],
	CONVERT(datetime, '9999-12-31')										AS [Valid To]
FROM	
	[Sales_DB].[dbo].[Customers] cus
	LEFT JOIN [Sales_DB].[dbo].[Addresses] badr on cus.BillingAddressID = badr.AddressID
	LEFT JOIN [Sales_DB].[dbo].[Cities] bcit on badr.CityID = bcit.CityID
	LEFT JOIN [Sales_DB].[dbo].[Provinces] bprv on bcit.ProvinceID = bprv.ProvinceID
	LEFT JOIN [Sales_DB].[dbo].[Countries] bcou on bprv.CountryID = bcou.CountryID
	LEFT JOIN [Sales_DB].[dbo].[Addresses] dadr on cus.DeliveryAddressID = dadr.AddressID
	LEFT JOIN [Sales_DB].[dbo].[Cities] dcit on dadr.CityID = dcit.CityID
	LEFT JOIN [Sales_DB].[dbo].[Provinces] dprv on dcit.ProvinceID = dprv.ProvinceID
	LEFT JOIN [Sales_DB].[dbo].[Countries] dcou on dprv.CountryID = dcou.CountryID

WHERE 
	([cus].ModifiedDate > @LastLoadDate AND [cus].ModifiedDate <= @NewLoadDate) OR
	([badr].ModifiedDate > @LastLoadDate AND [badr].ModifiedDate <= @NewLoadDate) OR
	([dadr].ModifiedDate > @LastLoadDate AND [dadr].ModifiedDate <= @NewLoadDate) 


    RETURN 0;
END;
GO


