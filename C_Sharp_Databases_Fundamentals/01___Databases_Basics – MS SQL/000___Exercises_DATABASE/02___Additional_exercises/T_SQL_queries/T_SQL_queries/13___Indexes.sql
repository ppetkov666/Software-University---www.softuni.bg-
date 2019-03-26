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
on Employees_test_table(name asc)

sp_helpindex Employees_test_table
-- if we want to drop it we just use
drop index Employees_test_table.emp_name

-- create clustered index

-- we cannot have more than one clustered index  so if we want to create this clustered index 
-- we have to drop the primary key first because by default it is unique clustered index constraint 
drop index Employees_test_table.PK__Employee__3214EC073303005D
-- we can do it from object explorer

create clustered index emp_gender_salary
on Employees_test_table(gender asc, salary asc)

-- we can add it in this way or in the beginning when we create the table , but in both ways will create  unique non clustered index
-- if we want explicitly to be clustered then we must do it in this way, but offcourse we must remove the existing PK
alter table Employees_test_table
add constraint unique_emp_city
unique clustered (city)