
-- 001 - ADD PRIMARY AND FOREIGN KEY INSIDE THE CREATE STATEMENT
-- 002 - ADD INDEX ON TABLE
-- 003 - ADD DEFAULT
-- 004 - ADD CHECK CONSTRAINT 
-- 005 - WITH
-- 006 - VIEW
-- 007 - STORED PROCEDURE
-- 008 - FUNCTION
-- 009 - CREATE INDEX
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

CREATE INDEX IX_TABLE_EMPLOYEES_SALARY
ON employees (salary asc)


select * from Employees

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

go
CREATE OR ALTER FUNCTION ufn_example
(
@salary INT
)										        
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN (select DISTINCT FirstName 
            from Employees 
           where Salary = @salary)   
END
GO
SELECT DBO.ufn_example (30000)
--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                009 
--------------------------------------------------------------------------------------------------------------------------------------------------
--  CREATE INDEX

CREATE INDEX ix_employees_salary ON Employees (Salary ASC)





--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                  010 
--------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE



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




---------------------------------------------------------------------------------------------------------------------------------------------------
--                                                               012 - TRIGGER
---------------------------------------------------------------------------------------------------------------------------------------------------

create trigger tr_forinsert on userinfo for insert 
as
begin

end






---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------





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

CREATE TABLE test_primary_change(
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
   set firstname = 'test', 
        lastname = 'testov' 
 where firstname = 'petko' and lastname = 'petkov'





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