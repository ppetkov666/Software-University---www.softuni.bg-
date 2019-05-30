
-- 001 - ADD PRIMARY AND FOREIGN KEY INSIDE THE CREATE STATEMENT
-- 002 - ADD INDEX ON TABLE 
-- 003 - ADD DEFAULT
-- 004 - ADD CHECK CONSTRAINT 
-- 005 - WITH
-- 006 - VIEW
-- 007 - STORED PROCEDURE
-- 008 - FUNCTION
-- 009 - ADD CONCATENATED FIELD AS SUM OF TWO FIELD 
-- 010 - UPDATE
-- 011 - CURSOR
-- 012 - TRIGGER

-- -------------- ALTER STATEMENTS

-- $001 - ADD FOREIGN KEY IN ALTER TABLE STATEMENT
-- $002 - ADD UNIQUE CONSTRAINT 
-- $003 - UPDATE COMPOSITE PRIMARY KEY
-- $004
-- $005
-- $006
-- $007
-- $008
-- $009
-- $010
-- $011
-- $012
-- $013
-- $014



-- ---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                001 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- ADD PRIMARY AND FOREIGN KEY INSIDE THE CREATE STATEMENT   


CREATE TABLE Students(
 id                                            INT               IDENTITY        NOT NULL,
 student_name                                  NVARCHAR(50)                      NOT NULL
 CONSTRAINT [PK_students]                      PRIMARY KEY ([id]), 
 )
 
 CREATE TABLE Courses(
 id                                            INT                IDENTITY       NOT NULL,
 course_name                                   NVARCHAR(50)                      NOT NULL
 CONSTRAINT [PK_Courses]                       PRIMARY KEY ([id]),
 )

 CREATE TABLE StudentCourses(
 [student_id] INT NOT NULL,
 [course_id] INT NOT NULL 
 CONSTRAINT [fk__StudentCourses_Courses]       FOREIGN KEY(course_id)        REFERENCES Courses(id), 
 CONSTRAINT [fk__StudentCourses_Students]      FOREIGN KEY(student_id)       REFERENCES Students(id) 
)
GO
CREATE TABLE EmployeesProjects(
    EmployeeID INT NOT NULL,
    ProjectID  INT NOT NULl
    -- composite primary key
    CONSTRAINT PK_EmployeesProjects             PRIMARY KEY (EmployeeID, ProjectID),
    CONSTRAINT FK_EmployeesProjects_Employees   FOREIGN KEY (EmployeeID)              REFERENCES Employees(EmployeeID),                                                                             
    CONSTRAINT FK_EmployeesProjects_Projects    FOREIGN KEY (ProjectID)               REFERENCES Projects(ProjectID)
)

------------------------------------------------------------------------------------------------------------------------------------------------
--                                                        002
------------------------------------------------------------------------------------------------------------------------------------------------
-- non unique , non clustered
-- it can be added in either way 
-- by adding a constraint or with CREATE statement
-- by default primary key constraint creates unique clustered index
CREATE INDEX IX_TABLE_EMPLOYEES_SALARY
ON employees (salary asc)

CREATE unique nonClustered INDEX IX_TABLE_EMPLOYEES_FIRSTNAME
ON employees (Firstname asc)


alter table tblEmployees
add constraint uq_tblEmployees_firstname
unique clustered


-- example :

use SoftUni

create TABLE Employees_test_table
(
 [Id] int Primary Key,
 [Name] nvarchar(50) ,
 [Salary] int check(salary > 1000),
 [Gender] nvarchar(10),
 [City] nvarchar(50)
)

Insert into Employees_test_table Values(3,'John',4500,'Male','New York')
Insert into Employees_test_table Values(1,'Sam',2500,'Male','London')
Insert into Employees_test_table Values(4,'Sara',5500,'Female','Tokyo')
Insert into Employees_test_table Values(5,'Todd',3100,'Male','Toronto')
Insert into Employees_test_table Values(2,'Pam',6500,'Female','Sydney')


-- create index
-- we can have multiple non clustered indexes  because they are actually a copy of the original table 
-- as analogy of book index
select * from Employees_test_table

create unique Nonclustered index emp_name
on Employees_test_table([Name] asc)

sp_helpindex Employees_test_table
-- if we want to drop it we just use
drop index Employees_test_table.emp_name

-- create clustered index

-- we cannot have more than one clustered index  so if we want to create this clustered index 
-- we have to drop the primary key first because by default it is unique clustered index constraint 
drop index Employees_test_table.PK__Employee__3214EC076B3A29E6
-- we can do it from object explorer

create clustered index emp_gender_salary
on Employees_test_table(gender asc, salary asc)

-- we can add it in this way or in the beginning when we create the table , but in both ways will create  unique non clustered index
-- if we want explicitly to be clustered then we must do it in this way, but offcourse we must remove the existing PK or clustered index 
drop index Employees_test_table.emp_gender_salary

alter table Employees_test_table
add constraint unique_emp_city
unique clustered (city)


-- ----------------------------------------------------------------------------------------------------------------------------------------------
--                                                           003  
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- ADD DEFAULT


ALTER TABLE [dbo].[my_table] 
ADD  CONSTRAINT [df__my_table__column_name]  
DEFAULT ((0)) FOR [effective_seconds]
GO
-- if does not have much to be explained  these are default values for certain columns 
------------------------------------------------------------------------------------------------------------------------------------------------ 
--                                                            004 
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- ADD CHECK CONSTRAINT 



ALTER TABLE [dbo].[my_table]  WITH NOCHECK ADD  
CONSTRAINT [CK_firstname_null_or_not_null] 
CHECK  (([FirstName] IS NULL OR [FirstName] IS NOT NULL))
GO


ALTER TABLE UserInfoTable
ADD CONSTRAINT FirstName
CHECK(LEN(FirstName) > 1)
--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                              005 
--------------------------------------------------------------------------------------------------------------------------------------------------
-- WITH



go
with cte_example
as
(
  select * from Employees
)

select firstname from cte_example

--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                               006                                                                
--------------------------------------------------------------------------------------------------------------------------------------------------
-- VIEW



go
create or alter view v_example_view
as
(
  select * from Employees
)
go
select * from v_example_view




--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                 007
--------------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURE


go
create or alter procedure spe_example
(
@firstname VARCHAR(50)
)
as
begin
  select * 
    from Employees 
   where FirstName = @firstname
end

exec spe_example 'guy'



---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                   008
---------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
use SoftUni
go
CREATE OR ALTER FUNCTION ufn_example
(
@salary INT
)										        
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN (SELECT DISTINCT FirstName 
            FROM Employees 
           WHERE Salary = @salary)   
END
GO
SELECT DBO.ufn_example (30000)


use UserInfo
-- syntax of function 
-- 1 - when returns a table
  go
  create or alter function test_funk_inline()
  returns table
  as
    return  select * from UserInfoTable
  go
  select * from dbo.test_funk_inline()

-- 2 - when returns a table variable
  go
  create or alter function test_funk_multi()
  returns @table_var table (firstname nvarchar(50), lastname nvarchar(50))
  as
  begin
    insert into @table_var   
    select uit.FirstName, uit.LastName from UserInfoTable uit
    return 
  end
  go
  select * from dbo.test_funk_multi()

-- 3 - when returns a result (int in this particular case)
  go
  create or alter function test_funk_normal_result()
  returns int
  
  begin
    declare @result int = (select sum(uit.Salary) from UserInfoTable uit)
     return @result
  end

  go
  
  select  [dbo].[test_funk_normal_result]()

--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                009 
--------------------------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE tbl_example(
  FirstName varchar(50),
	LastName varchar(50),
	FullName AS CONCAT(FirstName , ' ', LastName) --- > this is field as sum of 2 previous fields
)

INSERT INTO tbl_example
VALUES
('ivan','ivanov')

select * from tbl_example



--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  010 
--------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE

select * from UsersGames
select * from Users
select * from Games


 UPDATE ug
    SET Cash += 50000
   FROM UsersGames ug
   JOIN Users u ON u.Id = ug.UserId
   JOIN Games g ON g.Id = ug.GameId
  WHERE u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
    AND g.Name = 'Bali'


    UPDATE UserInfoTable
   SET Salary = 600
 WHERE Id = 6 AND LastName = 'PETKOV'
---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                   011 
---------------------------------------------------------------------------------------------------------------------------------------------------
-- CURSOR


GO
DECLARE @v_usergames_id  INT
  
  DECLARE example_cursor cursor for
  -- SELECT ug.Id
  --   FROM UsersGames ug
  --   JOIN Users u on u.Id = ug.UserId
  --   JOIN Games g on g.Id = ug.GameId
  --  WHERE u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
  --    AND g.Name = 'Bali'
  
  OPEN example_cursor
  FETCH NEXT FROM example_cursor INTO @v_usergames_id 

  WHILE @@FETCH_STATUS <> -1 BEGIN
   --update UsersGames
   --   set  Cash += 50000
   -- where Id = @v_usergames_id
    
    FETCH NEXT FROM example_cursor INTO @v_usergames_id 
  END
  CLOSE example_cursor
  DEALLOCATE example_cursor


GO
-- different types of cursors :
use SoftUni
-- by default cursor: it is FORWARD_ONLY by default OR SCROLL (THESE ARE DATA FETCH OPTIONS)

-- it could be also(THESE ARE DIFFERENT TYPE OF CURSORS): 
-- STATIC : create copy of SELECT statement into temp db 
-- DYNAMIC : the most flexible type of cursor... more details in MSDN
-- KEYSET : create copy of key values of our selected data, we can't see added or deleted records
-- FAST_FORWARD : this is by default cursor, it is forward only cursor specifically when we dont want to make any changes
-- it has performance optimisations (it is READ_ONLY)

-- type of locks:
-- READ_ONLY : PREVENT ANY CHANGES OF DATA..., CURSOR CANNOT BE UPDATED OR DELETED WHATSOEVER

-- SCROLL_LOCKS : allow changes to the table,
-- Provides data integrity into the cursor. 
-- It specifies that the cursor will lock the rows as they are read into the cursor to ensure 
-- that updates or deletes made using the cursor will succeed.
-- shortly said: LOCK THE ROW TO GUARANTEE THAT OUR CHANGES WILL SUCCEED, AND PREVENT USERS TO MAKE CHANGES TO IT

-- OPTIMISTIC - LOCK THE RECORD WHO TRY TO CHANGE, IF ANOTHER USER MADE CHANGES BEFORE THAT, MY UPDATE WOULD FAIL
-- IF THERE IS NO CHANGE CURSOR CAN UPDATE 

-- this is example how to combine different options to cursor and Update also 
begin tran
declare @v_salary int
declare @v_total_salary int set @v_total_salary = 0

declare test_cursor cursor GLOBAL FORWARD_ONLY /*STATIC READ_ONLY*/  
    for select 
        e.Salary 
   from Employees_test_table e
    for update of sum_salary
  
   open test_cursor
    fetch next from test_cursor into @v_salary
    while @@FETCH_STATUS <> -1
    begin
      set @v_total_salary += @v_salary
       
       update Employees_test_table
       set sum_salary = @v_total_salary
       where current of test_cursor


    fetch next from test_cursor into @v_salary
    end
  close test_cursor
deallocate test_cursor

select * from Employees_test_table
alter table Employees_test_table
add  sum_salary int default 0
commit

-- SCROLL
-- could go forward and backward
declare test_cursor cursor /*LOCAL or GLOBAL*/ SCROLL for 
 select e.FirstName,
        e.LastName 
   from Employees e
  open test_cursor
    fetch FIRST /*LAST*/ /*ABSOLUTE*/ from test_cursor
    while @@FETCH_STATUS <> -1
    begin
    
    fetch NEXT /*PRIOR*/ /*RELATIVE*/ from test_cursor 
    end
  close test_cursor
deallocate test_cursor

-- could go on each 10 .. row forward or backward only by using - minus
DECLARE test_cursor cursor SCROLL for 
 select e.FirstName,
        e.LastName 
   from Employees e
  open test_cursor
    fetch ABSOLUTE 10 from test_cursor
    while @@FETCH_STATUS <> -1
    begin
    
    fetch RELATIVE 10 from test_cursor 
    end
  close test_cursor
deallocate test_cursor

select * from Employees





---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                               012 - TRIGGER
---------------------------------------------------------------------------------------------------------------------------------------------------

create trigger tr_forinsert on userinfo for insert 
as
begin

end






---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------


PRINT @@TRANCOUNT  
--  The BEGIN TRAN statement will increment the  
--  transaction count by 1.  
BEGIN TRAN  
    PRINT @@TRANCOUNT  
    BEGIN TRAN  
        PRINT @@TRANCOUNT  
--  The COMMIT statement will decrement the transaction count by 1.  
    COMMIT  
    PRINT @@TRANCOUNT  
COMMIT  
PRINT @@TRANCOUNT  
--Results  
--0  
--1  
--2  
--1  
--0  


---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------







---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                $001 - ADD FOREIGN KEY  IN ALTER TABLE STATEMENT
---------------------------------------------------------------------------------------------------------------------------------------------------


ALTER TABLE [dbo].[my_table]  WITH NOCHECK --(not checking existing rows before adding the constraint)
ADD  CONSTRAINT [fk__my_table__other_table] 
FOREIGN KEY([column_name_one], [column_name_two], [column_name_three])
REFERENCES [dbo].[other_table] ([column_name_one], [column_name_two], [column_name_three])
GO
-- if it has to be explained it 'says': alter my table and add me a constraint with name which will include 'fk' which is sign for foreign key then the name of my table
-- and then the name of the next table.After that 'foreign key' are the columns in my table which are foreign keys and pointing to the other table
-- and the last part is references which include the name of the other table and it's columns primary keys


---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                         $002 - ADD UNIQUE CONSTRAINT 
---------------------------------------------------------------------------------------------------------------------------------------------------
USE UserInfo
select * from UserInfoTable
ALTER TABLE UserInfoTable
ADD CONSTRAINT uq_test_constraint Unique(firstname)

ALTER TABLE UserInfoTable
drop constraint uq_test_constraint 

---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                          $003 - 
---------------------------------------------------------------------------------------------------------------------------------------------------
-- update composite primary key 

create TABLE test_primary_change(
[firstname] NVARCHAR(10) NOT NULL,
[lastname] NVARCHAR(18) NOT NULL,
Constraint pk__test_primary_change primary key ([firstname], [lastname])
)
select * from test_primary_change

insert into test_primary_change
values 
('petko','petkov'),
('ivan','ivanov'),
('georgi','georgiev')

update test_primary_change 
   set firstname = 'petko', 
        lastname = 'petkov' 
 where firstname = 'ivan' and lastname = 'ivanov'


 create clustered index ci_primary_change on test_primary_change([firstname], [lastname])


---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                         $004 - 
---------------------------------------------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                          $005 - 
---------------------------------------------------------------------------------------------------------------------------------------------------






---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                         $006 - 
---------------------------------------------------------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                          $007 - 
---------------------------------------------------------------------------------------------------------------------------------------------------






---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                         $008 - 
---------------------------------------------------------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                          $009 - 
---------------------------------------------------------------------------------------------------------------------------------------------------