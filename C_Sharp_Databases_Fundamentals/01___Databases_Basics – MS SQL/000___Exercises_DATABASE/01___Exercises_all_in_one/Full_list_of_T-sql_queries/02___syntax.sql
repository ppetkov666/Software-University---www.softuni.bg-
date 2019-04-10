-- ---------------------------------------------------------------------------------------------------------------------------------------------------
--                                      ADD PRIMARY AND FOREIGN KEY INSIDE THE CREATE STATEMENT   
-- ---------------------------------------------------------------------------------------------------------------------------------------------------



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
--                                                        ADD FOREIGN KEY  IN ALTER TABLE STATEMENT
------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[my_table]  WITH NOCHECK --(not checking existing rows before adding the constraint)
ADD  CONSTRAINT [fk__my_table__other_table] 
FOREIGN KEY([column_name_one], [column_name_two], [column_name_three])
REFERENCES [dbo].[other_table] ([column_name_one], [column_name_two], [column_name_three])
GO
-- if it has to be explained it 'says': alter my table and add me a constraint with name which will include 'fk' which is sign for foreign key then the name of my table
-- and then the name of the next table.After that 'foreign key' are the columns in my table which are foreign keys and pointing to the other table
-- and the last part is references which include the name of the other table and it's columns primary keys
-- ----------------------------------------------------------------------------------------------------------------------------------------------
--                                                           ADD DEFAULT  
-- ----------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[my_table] 
ADD  CONSTRAINT [df__my_table__column_name]  
DEFAULT ((0)) FOR [effective_seconds]
GO
-- if does not have much to be explained  these are default values for certain columns 
------------------------------------------------------------------------------------------------------------------------------------------------ 
--                                                        ADD CHECK CONSTRAINT  
-- ----------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE [dbo].[my_table]  WITH NOCHECK ADD  
CONSTRAINT [CK_firstname_null_or_not_null] 
CHECK  (([FirstName] IS NULL OR [FirstName] IS NOT NULL))
GO


ALTER TABLE UserInfoTable
ADD CONSTRAINT FirstName
CHECK(LEN(FirstName) > 1)
--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                              WITH 
--------------------------------------------------------------------------------------------------------------------------------------------------
go
with cte_example
as
(
  select * from Employees
)

select firstname from cte_example

--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                               VIEW                                                                
--------------------------------------------------------------------------------------------------------------------------------------------------
go
create or alter view v_example_view
as
(
  select * from Employees
)
go
select * from v_example_view




--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                        STORED PROCEDURE
--------------------------------------------------------------------------------------------------------------------------------------------------
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
--                                                        FUNCTION
---------------------------------------------------------------------------------------------------------------------------------------------------

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
--                                                          CREATE INDEX
--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE INDEX ix_employees_salary ON Employees (Salary ASC)





--------------------------------------------------------------------------------------------------------------------------------------------------
--                                                            UPDATE 
--------------------------------------------------------------------------------------------------------------------------------------------------
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
--                                                           cursor
---------------------------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------------------------







---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------







---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------