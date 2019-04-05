

------------------------------------------------------------------------------------------------------------------------------------------------

-- ADD FOREIGN KEY 

ALTER TABLE [dbo].[my_table]  WITH NOCHECK --(not checking existing rows before adding the constraint)
ADD  CONSTRAINT [fk__my_table__other_table] 
FOREIGN KEY([column_name_one], [column_name_two], [column_name_three])
REFERENCES [dbo].[other_table] ([column_name_one], [column_name_two], [column_name_three])
GO
-- if it has to be explained it 'says': alter my table and add me a constraint with name which will include 'fk' which is sign for foreign key then the name of my table
-- and then the name of the next table.After that 'foreign key' are the columns in my table which are foreign keys and pointing to the other table
-- and the last part is references which include the name of the other table and it's columns primary keys
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- ADD DEFAULT  

ALTER TABLE [dbo].[my_table] 
ADD  CONSTRAINT [df__my_table__column_name]  
DEFAULT ((0)) FOR [effective_seconds]
GO
-- if does not have much to be explained  these are default values for certain columns 
----------------------------------------------------------------------------------------------------------------- 

-- ADD CHECK CONSTRAINT  

ALTER TABLE [dbo].[my_table]  WITH NOCHECK ADD  
CONSTRAINT [CK_firstname_null_or_not_null] 
CHECK  (([FirstName] IS NULL OR [FirstName] IS NOT NULL))
GO
-- --------------------------------------------------------------------------------------------------------------------

-- ADD PRIMART AND FOREIGN KEY INSIDE THE CREATE STATEMENT   


CREATE TABLE EmployeesProjects(
    EmployeeID INT NOT NULL,
    ProjectID  INT NOT NULl

    CONSTRAINT PK_EmployeesProjects
    PRIMARY KEY (EmployeeID, ProjectID),

    CONSTRAINT FK_EmployeesProjects_Employees
    FOREIGN KEY (EmployeeID) 
    REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_EmployeesProjects_Projects
    FOREIGN KEY (ProjectID) 
    REFERENCES Projects(ProjectID)
)

--------------------------------------------------------------------------------------------------------------------------------------------------

select * from products_test pt
alter table products_test 
alter column Name nvarchar(999)

--------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------