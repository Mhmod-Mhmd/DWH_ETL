use Sales_WH
go

declare @return_value int

exec @return_value = load_DimDate 
	@StartDate = '2008-01-01',
	@EndDate = '2025-12-31'

select 'return sp value' = @return_value


select * from track.[IncrementalLoads]
select * from track.lineage

