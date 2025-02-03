USE [Sales_DB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Create or modify the procedure for loading data into the staging table
create or Alter   PROCEDURE [dbo].[Load_StagingEmployee]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	 'HSD|' + CONVERT(NVARCHAR, emp.[EmployeeID])				AS [_SourceKey]
	,	CONCAT_WS('|', 'HSD', 
		CONVERT(nvarchar(5), ISNULL(cou.CountryID, 0)),
		CONVERT(nvarchar(5), ISNULL(prv.ProvinceID, 0)),
		CONVERT(nvarchar(5), ISNULL(cit.CityID, 0)), 
		CONVERT(nvarchar(5), ISNULL(adr.AddressID, 0)))			AS [Location Key]
	,CONVERT(nvarchar(100),emp.LastName)						AS [Last Name]
	,CONVERT(nvarchar(100),emp.FirstName)						AS [First Name]
	,CONVERT(nvarchar(25),emp.Title)							AS [Title]
	,CONVERT(date,emp.BirthDate)								AS [Birth Date]
	,CONVERT(nvarchar(10),emp.Gender)							AS [Gender]
	,CONVERT(date,emp.HireDate)									AS [Hire Date]
	,CONVERT(nvarchar(100),emp.JobTitle)						AS [Job Title]
	,CONVERT(nvarchar(100),adr.AddressLine1)					AS [Address Line]
	,CONVERT(nvarchar(100),cit.CityName)						AS [City]
	,CONVERT(nvarchar(100),cou.CountryName)						AS [Country]
	,'HSD|' + CONVERT(NVARCHAR, emp.ManagerID)					AS [Manager Key]
	,CONVERT(datetime, ISNULL(emp.ModifiedDate, '1753-01-01'))	AS [Employee Modified Date]
	,CONVERT(datetime, ISNULL(adr.ModifiedDate, '1753-01-01'))	AS [Address Modified Date]
	,(SELECT MAX(t) FROM
                             (VALUES
                               ([emp].ModifiedDate)
                             , ([adr].ModifiedDate)
                             ) AS [maxModifiedDate](t)
                           )								AS [ValidFrom]
	,CONVERT(datetime, '9999-12-31')						AS [ValidTo]
FROM [Sales_DB].[dbo].[Employees] [emp]
LEFT JOIN [Sales_DB].[dbo].[Addresses] [adr] ON emp.AddressID = adr.AddressID
LEFT JOIN [Sales_DB].[dbo].Cities [cit] ON adr.CityID = cit.CityID
LEFT JOIN [Sales_DB].[dbo].Provinces [prv] ON cit.ProvinceID = prv.ProvinceID
LEFT JOIN [Sales_DB].[dbo].Countries [cou] ON prv.CountryID = cou.CountryID
WHERE 
	([emp].ModifiedDate > @LastLoadDate AND [emp].ModifiedDate <= @NewLoadDate) OR
	([adr].ModifiedDate > @LastLoadDate AND [adr].ModifiedDate <= @NewLoadDate) 

    RETURN 0;
END;
GO


