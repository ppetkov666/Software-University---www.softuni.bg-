

-- Schema  explanation -- Distinct namespace to facilitate the separation, management and the ownership of database objects

-- it is like a house with rooms and furnitures
-- if my database is Called SoftUni then:
--> House = SoftUni
--> RoomOne: Bed, Chair --> part of Test schema
--> RoomTwo: Bed, Chair --> part of SecondTest schema  
--> DefaultRoom: Bed, Chair --> part of Dbo Schema

-- we divide our objects in database in different "rooms" which are schemas  , we can think of schemas also as a sub contrainers which are part 
-- of the big container who is our database 
-- we can create same table in different schemas but we must specify before that ..Example :
-->Create table TestSchema.People
-->Create table SecondTestSchema.People

--> demonstration how to move objects from one schema to another  
-- first create schema and  object (table) into this schema
go
create schema test

CREATE TABLE [test].[EmployeesTest](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[MiddleName] [varchar](50) NULL,
	[JobTitle] [varchar](50) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[ManagerID] [int] NULL,
	[HireDate] [smalldatetime] NOT NULL,
	[Salary] [money] NOT NULL,
	[AddressID] [int] NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- after i want to change the name ot this schema but  it is not allowed  - does not matter with f2 or right click Rename - i can just change the name of the table
-- so thay is why i will create new schema with name 'T' and move Employees table to the new Schema
go
create schema T
-- when we alter it one by one is ok but if we have many object then we need different approach
alter schema T 
transfer [test].[Employees]


-- this is the other approach when we have to transfer many tables at once
go
declare @output_variable nvarchar(max)
set @output_variable = 'select ''Alter Schema T transfer [''+ SCHEMA_NAME(schema_id)+''].[''+name+'']'' as myQuerie from sys.objects
where SCHEMA_NAME(schema_id) = ''test''' 

EXECUTE sp_executesql @output_variable

-- or like this with declared variables
Declare @SourceSchema VARCHAR(100)   SET @SourceSchema='test';
Declare @DestinationSchema VARCHAR(100)  SET @DestinationSchema='T';

select 'Alter Schema ['+@DestinationSchema+'] Transfer ' + @SourceSchema+'.['+name+']' 
from sys.objects
where schema_name(schema_id)=@SourceSchema
-- then we execute it - copy the result and execute it- in this case  this is the following result:
Alter Schema [T] Transfer test.[EmployeesTest]
Alter Schema [T] Transfer test.[PK_Employees]


go
select obj.*,sch.name from sys.objects obj                            
join sys.schemas sch on sch.schema_id = obj.schema_id
where type_desc = 'user_table'
go


-- this is how we can check all the schemas
select * from sys.schemas
























