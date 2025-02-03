USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
CREATE or Alter PROCEDURE [dbo].[Load_StagingSales]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT CAST(ord.OrderDate AS date)								AS [_SourceOrderDateKey],
           CAST(ord.DeliveryDate AS date)							AS [_SourceDeliveryDateKey],
           ord.OrderID												AS [_SourceOrder],
		   ISNULL(orl.OrderLineID, 0)								AS [_SourceOrderLine],
		   cus.CustomerID											AS [_SourceCustomerKey],
		   emp.EmployeeID											AS [_SourceEmployeeKey],
		   prd.ProductID											AS [_SourceProductKey],
		   pmt.PaymentTypeID										AS [_SourcePaymentTypeKey],
		   cou.CountryID											AS [_SourceDeliveryCountryKey],
		   prv.ProvinceID											AS [_SourceDeliveryProvinceKey],
		   cit.CityID												AS [_SourceDeliveryCityKey],
		   adr.AddressID											AS [_SourceDeliveryAddressKey],
		   CONCAT_WS('|', cou.CountryID, 
			prv.ProvinceID,
			cit.CityID,
			adr.AddressID)											AS [_SourceDeliveryLocationKey],
		   pro.PromotionID											AS [_SourcePromotionKey],
		   ISNULL(orl.Description, 'N/A)')							AS [Description],
           ISNULL(pck.PackageTypeName, 'N/A')						AS [Package],
           orl.Quantity												AS [Quantity],
           orl.UnitPrice											AS [Unit Price],
           ISNULL(orl.VATRate, 0.20)								AS [VAT Rate],
           orl.Quantity * orl.UnitPrice								AS [Total Excluding VAT],
		   orl.Quantity * orl.UnitPrice * ISNULL(orl.VATRate, 0.20) AS [VAT Amount],
		   orl.Quantity*orl.UnitPrice*(1+ ISNULL(orl.VATRate, 0.20)) AS [Total Including VAT],
           CASE 
			WHEN orl.ModifiedDate > ord.ModifiedDate 
				THEN orl.ModifiedDate 
			ELSE ord.ModifiedDate END								AS [ModifiedDate]
    FROM 
		[Sales_DB].[dbo].[Orders] ord
		LEFT JOIN [Sales_DB].[dbo].[OrderLines] orl ON ord.OrderID = orl.OrderID
	    LEFT JOIN [Sales_DB].[dbo].[Customers] cus ON ord.CustomerID = cus.CustomerID
		LEFT JOIN [Sales_DB].[dbo].[Addresses] adr ON ord.DeliveryAddressID = adr.AddressID
		LEFT JOIN [Sales_DB].[dbo].[Cities] cit ON adr.CityID = cit.CityID
		LEFT JOIN [Sales_DB].[dbo].[Provinces] prv ON cit.ProvinceID = prv.ProvinceID
		LEFT JOIN [Sales_DB].[dbo].[Countries] cou ON prv.CountryID = cou.CountryID
	    LEFT JOIN [Sales_DB].[dbo].[Employees] emp ON ord.EmployeeID = emp.EmployeeID
        LEFT JOIN [Sales_DB].[dbo].[PaymentTypes] pmt ON ord.PaymentTypeID = pmt.PaymentTypeID
		LEFT JOIN [Sales_DB].[dbo].[Products] prd ON orl.ProductID = prd.ProductID
		LEFT JOIN [Sales_DB].[dbo].[PackageTypes] pck ON orl.PackageTypeID = pck.PackageTypeID 
		LEFT JOIN [Sales_DB].[dbo].[Promotions] pro ON orl.PromotionID = pro.PromotionID
WHERE 
	([ord].ModifiedDate > @LastLoadDate AND [ord].ModifiedDate <= @NewLoadDate) OR
	([orl].ModifiedDate > @LastLoadDate AND [orl].ModifiedDate <= @NewLoadDate) 


    RETURN 0;
END;
GO


