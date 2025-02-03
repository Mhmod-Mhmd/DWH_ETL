use Sales_WH
go 

CREATE TABLE [dbo].[Dim_Customer](
	[Customer Key] int IDENTITY(1,1) NOT NULL,
	[_Source Key] nvarchar(50) NOT NULL,
	[First Name] nvarchar(100) NOT NULL,
	[Last Name] nvarchar(100) NOT NULL,
	[Full Name]  AS (([First Name]+' ')+[Last Name]),
	[Title] nvarchar(30) NOT NULL,
	[Delivery Location Key] nvarchar(50) NOT NULL,
	[Billing Location Key] nvarchar(50) NOT NULL,
	[Phone Number] nvarchar(24) NOT NULL,
	[Email] nvarchar(100) NULL,
	[Valid From] datetime NOT NULL,
	[Valid To] datetime NOT NULL,
	[Lineage Key] int NOT NULL,
 CONSTRAINT [PK_Dim_Customer] PRIMARY KEY ([Customer Key])
 ) 

go
CREATE TABLE dbo.Dim_Employee(
	[Employee Key] int IDENTITY(1,1) NOT NULL,
	[_Source Key] nvarchar(50) NOT NULL,
	[Location Key] nvarchar(50) NOT NULL,
	[Last Name] nvarchar(100) NOT NULL,
	[First Name] nvarchar(100) NOT NULL,
	[Title] nvarchar(30) NOT NULL,
	[Birth Date] datetime NOT NULL,
	[Gender] nchar(10) NOT NULL,
	[Hire Date] datetime NOT NULL,
	[Job Title] nvarchar(100) NOT NULL,
	[Address Line] nvarchar(100) NULL,
	[City] nvarchar(100) NULL,
	[Country] nvarchar(100) NULL,
	[Manager Key] nvarchar(50) NULL,
	[Valid From] datetime NOT NULL,
	[Valid To] datetime NOT NULL,
	[Lineage Key] int NOT NULL,
 CONSTRAINT [PK_Dim_Employee] PRIMARY KEY ([Employee Key]) 
 )
go 

CREATE TABLE [dbo].[Dim_Date](
	[Date Key] int NOT NULL,
	[Date] date NOT NULL,
	[Day] tinyint NOT NULL,
	[Day Suffix] char(2) NOT NULL,

	[Weekday] tinyint NOT NULL,
	[Weekday Name] varchar(10) NOT NULL,
	[Weekday Name Short] char(3) NOT NULL,
	[Weekday Name FirstLetter] char(1) NOT NULL,

	[Day Of Year] smallint NOT NULL,
	[Week Of Month] tinyint NOT NULL,
	[Week Of Year] tinyint NOT NULL,

	[Month] tinyint NOT NULL,
	[Month Name] varchar(10) NOT NULL,
	[Month Name Short] char(3) NOT NULL,
	[Month Name FirstLetter] char(1) NOT NULL,

	[Quarter] tinyint NOT NULL,
	[Quarter Name] varchar(6) NOT NULL,
	[Year] int NOT NULL,
	[MMYYYY] char(6) NOT NULL,
	[Month Year] char(7) NOT NULL,

	[Is Weekend] bit NOT NULL,
	[Is Holiday] bit NOT NULL,

	[Holiday Name] varchar(20) NOT NULL,
	[Special Day] varchar(20) NOT NULL,

	[First Date Of Year] date NULL,
	[Last Date Of Year] date NULL,
	[First Date Of Quater] date NULL,
	[Last Date Of Quater] date NULL,
	[First Date Of Month] date NULL,
	[Last Date Of Month] date NULL,
	[First Date Of Week] date NULL,
	[Last Date Of Week] date NULL,

	[Lineage Key] int NULL,
Constraint [PK_Dim_Date] PRIMARY KEY ([Date Key])
)
Go

Alter table Dim_Date add default (0) for [Is Weekend];
go
Alter table Dim_Date add default (0) for [Is Holiday];
go
Alter table Dim_Date add default ('') for [Holiday Name];
go 
Alter table Dim_date add default ('') for [Special Day];

Go

CREATE TABLE [dbo].Dim_Location(
	[Location Key] int IDENTITY(1,1) NOT NULL,
	[_Source Key] nvarchar(200) NOT NULL,
	[Continent] nvarchar(200) NOT NULL,
	[Region] nvarchar(200) NOT NULL,
	[Subregion] nvarchar(200) NOT NULL,
	[Country Code] nvarchar(50) NULL,
	[Country] nvarchar(200) NOT NULL,
	[Country Formal Name] nvarchar(200) NOT NULL,
	[Country Population] bigint NULL,
	[Province Code] nvarchar(200) NOT NULL,
	[Province] nvarchar(200) NOT NULL,
	[Province Population] bigint NULL,
	[City] nvarchar(200) NOT NULL,
	[City Population] bigint NULL,
	[Address Line 1] nvarchar(200) NOT NULL,
	[Address Line 2] nvarchar(200) NULL,
	[Postal Code] nvarchar(200) NOT NULL,
	[Valid From] datetime NOT NULL,
	[Valid To] datetime NOT NULL,
	[Lineage Key] int NOT NULL,
 CONSTRAINT [PK_Dim_Location] PRIMARY KEY ([Location Key])
 )
 Go 

CREATE TABLE [dbo].[Dim_PaymentType](
	[Payment Type Key] [int] IDENTITY(1,1) NOT NULL,
	[_Source Key] [nvarchar](50) NOT NULL,
	[Payment Type Name] [nvarchar](50) NOT NULL,
	[Valid From] [datetime] NOT NULL,
	[Valid To] [datetime] NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_Dim_PaymentType] PRIMARY KEY ([Payment Type Key]) 
 )
 Go 

 CREATE TABLE [dbo].[Dim_Product](
	[Product Key] [int] IDENTITY(1,1) NOT NULL,
	[_Source Key] [nvarchar](50) NOT NULL,
	[Product Name] [nvarchar](200) NOT NULL,
	[Product Code] [nvarchar](50) NOT NULL,
	[Product Description] [nvarchar](200) NOT NULL,
	[Product Subcategory] [nvarchar](200) NOT NULL,
	[Product Category] [nvarchar](200) NOT NULL,
	[Product Department] [nvarchar](200) NOT NULL,
	[Unit Of Measure Code] [nvarchar](10) NOT NULL,
	[Unit Of Measure Name] [nvarchar](50) NOT NULL,
	[Unit Price] [decimal](18, 2) NOT NULL,
	[Discontinued] [nvarchar](10) NOT NULL,
	[Valid From] [datetime] NOT NULL,
	[Valid To] [datetime] NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_Dim_Product] PRIMARY KEY ([Product Key])
 )
 GO

 CREATE TABLE [dbo].[Dim_Promotion](
	[Promotion Key] [int] IDENTITY(1,1) NOT NULL,
	[_Source Key] [nvarchar](50) NOT NULL,
	[Deal Description] [nvarchar](30) NOT NULL,
	[Start Date] [date] NOT NULL,
	[End Date] [date] NOT NULL,
	[Discount Amount] [decimal](18, 2) NULL,
	[Discount Percentage] [decimal](18, 3) NULL,
	[Valid From] [datetime] NOT NULL,
	[Valid To] [datetime] NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_Dim_Promotion] PRIMARY KEY ([Promotion Key])
 )
 GO

 CREATE TABLE [dbo].[Fact_Sales](
	[Sale Key] [bigint] IDENTITY(1,1) NOT NULL,
	[Customer Key] [int] NOT NULL,
	[Employee Key] [int] NOT NULL,
	[Product Key] [int] NOT NULL,
	[Payment Type Key] [int] NOT NULL,
	[Order Date Key] [int] NOT NULL,
	[Delivery Date Key] [int] NULL,
	[Delivery Location Key] [int] NULL,
	[Promotion Key] [int] NOT NULL,

	[Description] [nvarchar](100) NOT NULL,
	[Package] [nvarchar](50) NOT NULL,

	[Quantity] [int] NULL,
	[Unit Price] [decimal](18, 2) NULL,
	[VAT Rate] [decimal](18, 3) NULL,
	[Total Excluding VAT] [decimal](18, 2) NULL,
	[VAT Amount] [decimal](18, 2) NULL,
	[Total Including VAT] [decimal](18, 2) NULL,

	[_SourceOrder] [nvarchar](50) NOT NULL,
	[_SourceOrderLine] [nvarchar](50) NOT NULL,

	[Lineage Key] [int] NOT NULL
)

