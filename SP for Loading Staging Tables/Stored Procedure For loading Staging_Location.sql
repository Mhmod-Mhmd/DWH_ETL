USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
create or Alter PROCEDURE [dbo].[Load_StagingLocation]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	CONCAT_WS('|', 'HSD', 
		CONVERT(nvarchar(5), ISNULL(cou.CountryID, 0)),
		CONVERT(nvarchar(5), ISNULL(prv.ProvinceID, 0)),
		CONVERT(nvarchar(5), ISNULL(cit.CityID, 0)), 
		CONVERT(nvarchar(5), ISNULL(adr.AddressID, 0)))						AS [_SourceKey],
	CONVERT(nvarchar(200),ISNULL(cou.Continent, 'N/A'))						AS [Continent],
	CONVERT(nvarchar(200),ISNULL(cou.Region, 'N/A'))						AS [Region],
	CONVERT(nvarchar(200),ISNULL(cou.Subregion, 'N/A'))						AS [Subregion],
	CONVERT(nvarchar(200), ISNULL(cou.CountryCode, 'N/A'))					AS [Country Code], 
	CONVERT(nvarchar(200), ISNULL(cou.CountryName, 'N/A'))					AS [Country], 
	CONVERT(nvarchar(200),ISNULL(cou.FormalName, 'N/A'))					AS [Country Formal Name],
	ISNULL(CONVERT(bigint,cou.Population), -1)								AS [Country Population],
	CONVERT(nvarchar(200),ISNULL(prv.ProvinceCode, 'N/A'))					AS [Province Code],
	CONVERT(nvarchar(200),ISNULL(prv.ProvinceName, 'N/A'))					AS [Province],
	ISNULL(CONVERT(bigint,prv.Population), -1)								AS [Province Population],
	CONVERT(nvarchar(200),ISNULL(cit.CityName, 'N/A'))						AS [City],
	ISNULL(CONVERT(bigint,cit.Population), -1)								AS [City Population],
	CONVERT(nvarchar(200),ISNULL(adr.PostalCode, 'N/A'))					AS [Postal Code],
	CONVERT(nvarchar(200),ISNULL(adr.AddressLine1, 'N/A'))					AS [Address Line 1],
	CONVERT(nvarchar(200),ISNULL(adr.AddressLine2, 'N/A'))					AS [Address Line 2],
	CONVERT(datetime, ISNULL([adr].ModifiedDate, '1753-01-01'))				AS [Address Modified Date],
	CONVERT(datetime, ISNULL([cit].ModifiedDate, '1753-01-01'))				AS [City Modified Date],
	CONVERT(datetime, ISNULL([prv].ModifiedDate, '1753-01-01'))				AS [Province Modified Date],
	CONVERT(datetime, ISNULL([cou].ModifiedDate, '1753-01-01'))				AS [Country Modified Date],
	(SELECT MAX(t) FROM
                             (VALUES
                               ([adr].ModifiedDate)
                             , ([cit].ModifiedDate)
                             , ([prv].ModifiedDate)
                             , ([cou].ModifiedDate)
                             ) AS [maxModifiedDate](t)
                           )												AS [ValidFrom],
	CONVERT(datetime, '9999-12-31')											AS [ValidTo]
FROM	
	[Sales_DB].[dbo].[Addresses] adr 
	FULL JOIN [Sales_DB].[dbo].[Cities] cit on adr.CityID = cit.CityID
	FULL JOIN [Sales_DB].[dbo].[Provinces] prv on cit.ProvinceID = prv.ProvinceID
	FULL JOIN [Sales_DB].[dbo].[Countries] cou on prv.CountryID = cou.CountryID
WHERE 
	([adr].ModifiedDate > @LastLoadDate AND [adr].ModifiedDate <= @NewLoadDate) OR
	([cit].ModifiedDate > @LastLoadDate AND [cit].ModifiedDate <= @NewLoadDate) OR
	([prv].ModifiedDate > @LastLoadDate AND [prv].ModifiedDate <= @NewLoadDate) OR
	([cou].ModifiedDate > @LastLoadDate AND [cou].ModifiedDate <= @NewLoadDate) 


    RETURN 0;
END;
GO


