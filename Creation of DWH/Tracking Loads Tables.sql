USE Sales_WH
go 

create schema track;
go 

CREATE TABLE track.IncrementalLoads(
	LoadDateKey int IDENTITY(1,1) NOT NULL,
	TableName nvarchar(100) NOT NULL,
	LoadDate datetime NOT NULL,
 CONSTRAINT [PK_IncrementalDates] PRIMARY KEY (LoadDateKey)
 );
 go

CREATE TABLE track.Lineage(
	LineageKey int IDENTITY(1,1) NOT NULL,
	TableName nvarchar(100) NOT NULL,
	StartLoad datetime not null,
	FinishLoad datetime null,
	LastLoadedDate datetime not null,
	States nvarchar(1) not null,
	Type nvarchar(1) not null,
	constraint PK_Lineage primary key (LineageKey)
)
go

Alter table track.Lineage add constraint DF_States default ('p') for States;
go 
alter table track.Lineage add constraint DF_Type default ('F') for Type;


