USE [Sales_DB]
GO
-- Create or modify the procedure for loading data into the staging table
CREATE OR ALTER PROCEDURE [dbo].[Load_StagingProduct]
@LastLoadDate datetime,
@NewLoadDate datetime
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

--SELECT @LastLoadDate, @NewLoadDate

SELECT 
	 'HSD|' + CONVERT(NVARCHAR, prod.[ProductID])			AS [_SourceKey]
	,CONVERT(nvarchar(200), prod.[ProductName])				AS [Product Name]
	,CONVERT(nvarchar(50), prod.[ProductCode])				AS [Product Code]
	,CONVERT(nvarchar(200), prod.[ProductDescription])		AS [Product Description]
	,CONVERT(nvarchar(200), subcat.[SubcategoryName])		AS [Subcategory]
	,CONVERT(nvarchar(200), cat.[CategoryName])				AS [Category]
	,CONVERT(nvarchar(200), dep.[Name])						AS [Department]
	,CONVERT(nvarchar(10), um.[UnitMeasureCode])			AS [Unit of measure Code]
	,CONVERT(nvarchar(50), um.[Name])						AS [Unit of measure Name]
	,CONVERT(decimal(18,2), prod.[UnitPrice])				AS [Unit Price]
	,CONVERT(nvarchar(10), CASE prod.[Discontinued]
		WHEN 1 THEN 'Yes'
		ELSE 'No'
	 END)													AS [Discontinued] 
	,CONVERT(datetime, ISNULL([prod].ModifiedDate, '1753-01-01'))	AS [Product Modified Date]
	,CONVERT(datetime, ISNULL([subcat].ModifiedDate, '1753-01-01'))	AS [Subcategory Modified Date]
	,CONVERT(datetime, ISNULL([cat].ModifiedDate, '1753-01-01'))	AS [Category Modified Date]
	,CONVERT(datetime, ISNULL([dep].ModifiedDate, '1753-01-01'))	AS [Department Modified Date]
	,CONVERT(datetime, ISNULL([um].ModifiedDate, '1753-01-01'))		AS [UM Modified Date]
	,(SELECT MAX(t) FROM
                             (VALUES
                               ([prod].ModifiedDate)
                             , ([subcat].ModifiedDate)
                             , ([cat].ModifiedDate)
                             , ([dep].ModifiedDate)
                             , ([um].ModifiedDate)
                             ) AS [maxModifiedDate](t)
                           )								AS [ValidFrom]
	,CONVERT(datetime, '9999-12-31')						AS [ValidTo]

FROM [Sales_DB].[dbo].[Products] prod
LEFT JOIN [Sales_DB].[dbo].[ProductSubcategories] subcat ON prod.SubcategoryID = subcat.ProductSubcategoryID
LEFT JOIN [Sales_DB].[dbo].[ProductCategories] cat ON subcat.ProductCategoryID = cat.CategoryID
LEFT JOIN [Sales_DB].[dbo].[ProductDepartments] dep ON cat.DepartmentID = dep.DepartmentID
LEFT JOIN [Sales_DB].[dbo].[UnitsOfMeasure] um ON prod.UnitOfMeasureID = um.UnitOfMeasureID
WHERE 
	([prod].ModifiedDate > @LastLoadDate AND [prod].ModifiedDate <= @NewLoadDate) OR
	([subcat].ModifiedDate > @LastLoadDate AND [subcat].ModifiedDate <= @NewLoadDate) OR
	([cat].ModifiedDate > @LastLoadDate AND [cat].ModifiedDate <= @NewLoadDate) OR
	([dep].ModifiedDate > @LastLoadDate AND [dep].ModifiedDate <= @NewLoadDate) OR
	([um].ModifiedDate > @LastLoadDate AND [um].ModifiedDate <= @NewLoadDate)

    RETURN 0;
END;