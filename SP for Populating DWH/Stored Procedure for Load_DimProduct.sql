use Sales_WH
go 

create or alter procedure Load_DimProduct
as
begin
	
	DECLARE @EndOfTime datetime = '9999-12-31';
	DECLARE @LastDateLoaded datetime;

	begin tran;
		
		-- get linagekey
		declare @lineagekey int = (select max(lineagekey)
							  from track.Lineage 
							  where TableName = 'Dim_Product'
							  and FinishLoad is null)

		
		IF NOT EXISTS (SELECT * FROM Dim_Product WHERE [_Source Key] = '')
		INSERT INTO [dbo].[Dim_Product]
           ([_Source Key]
           ,[Product Name]
           ,[Product Code]
           ,[Product Description]
           ,[Product Subcategory]
           ,[Product Category]
           ,[Product Department]
           ,[Unit Of Measure Code]
           ,[Unit Of Measure Name]
           ,[Unit Price]
           ,[Discontinued]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
     VALUES
           ('', 'N/A', 'N/A','N/A','N/A','N/A','N/A','N/A','N/A', -1, 'N/A', '1753-01-01', '9999-12-31', -1)

		-- update dim_product table if there is any changes in data from staging table
	update dim_product
		set dim_product.[Valid To] = Staging_Product.[Valid From]
		from Dim_Product join Staging_Product 
		on Dim_Product.[_Source Key] = Staging_Product.[_Source Key]
		where Dim_Product.[Valid To] = @EndOfTime

		-- insert data to dim_product from staging table
		-- Insert new rows for the modified products
	INSERT Dim_Product
		    ([_Source Key]
           ,[Product Name]
           ,[Product Code]
           ,[Product Description]
           ,[Product Subcategory]
           ,[Product Category]
           ,[Product Department]
           ,[Unit Of Measure Code]
           ,[Unit Of Measure Name]
           ,[Unit Price]
           ,[Discontinued]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    SELECT [_Source Key]
           ,[Product Name]
           ,[Product Code]
           ,[Product Description]
           ,[Product Subcategory]
           ,[Product Category]
           ,[Product Department]
           ,[Unit Of Measure Code]
           ,[Unit Of Measure Name]
           ,[Unit Price]
           ,[Discontinued]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM Staging_Product;

	-- Update the lineage table for the most current Dim_Product load with the finish date and 
	-- 'S' in the Status column, meaning that the load finished successfully
	UPDATE track.Lineage
        SET 
			FinishLoad = SYSDATETIME(),
            Status = 'S',
			@LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;
	 
	
	-- Update the LoadDates table with the most current load date for Dim_Product
	UPDATE track.IncrementalLoads
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'Dim_Product';

    -- All these tasks happen together or don't happen at all. 
	COMMIT;

    RETURN 0;
END;
GO
