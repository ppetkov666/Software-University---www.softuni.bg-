

-- 001 : HOW TO take a employee with 3-rd highest salary 
-- 002 : HOW TO take all managers of particular employee
-- 003 : HOW TO delete dublicate rows
-- 004 : HOW TO find employees hired in last N-th month
-- 005 : HOW TO find department with highes number of employees
-- 006 : HOW TO find count of people grouped by departent and town name using 3 join statements 
-- 007 : HOW TO find all names that start with certain letter without like operator
-- 008 : HOW TO insert into many to many table
-- 009 : HOW TO get people after, before or between certain date
-- 010 : HOW TO insert full list of records from one table to another and adding additional empthy columns
-- 011 : HOW TO get the products without any sales
             -- get products and their sold quantities
             -- generate random numbers
             -- how to use STUFF with FOR XML PATH with example:
-- 012 : HOW TO use INFORMATION_SCHEMA and SYS object 
-- 013 : HOW TO group by different criteria in one table
-- 014 : HOW TO use OVER with partition by and order by 
-- 015 : HOW TO get running total value as additional column
-- 016 : HOW TO check for dependency in any sp (SYS)
-- 017 : HOW TO create sequence and set increment value
-- 018 : HOW TO insert the data from 2 tables into third table using guid
-- 019 : HOW TO use cross apply 
-- 020 : HOW TO get count of emp by certain criteria on each row with other columns
-- 021 : HOW TO get only UNmatching record from 2 tables
-- 022 : HOW TO find employee which name is [example]... 
-- 023 : HOW TO set multiple variables in SELECT statement 
-- 024 : HOW TO compare two result sets using EXCEPT 
-- 025 : HOW TO check if temp table is created or empthy with EXISTS operator
-- 026 : HOW TO execute bulk delete with SP
-- 027 : HOW TO update all Salaries with random data in table using SP
-- 028 : HOW TO check isolation levels on DB
-- 029 : HOW TO insert from one table to another 
-- 030 : HOW TO create COPY of existing table in the fastest possible way
-- 031 : HOW TO explain difference between WHERE clause and HAVING clause with example
-- 032 : HOw TO create SYNONYM and truncate it using stored procedure
-- 033 : HOW TO create querie with BETTER performace comparing 4 different examples
-- 034 : HOW TO add a one digit after decimal point and to return it as nvarchar
-- 035 : HOW TO find open TRANSACTIONS IN SQL SERVER

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             001
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                          -- HOW TO take a employee with 3-rd highest salary
-- off course here row number will not work quite correctly in some cases but this is not the case for this example

select * from Employees

SELECT emp.FirstName,
       emp.LastName,
       emp.Salary
  FROM (SELECT e.FirstName,
               e.LastName,
               e.Salary,
               ROW_NUMBER() OVER (ORDER BY e.salary DESC) 'row number' 
          FROM Employees e ) AS emp
 WHERE [row number] = 3

 GO
 -- second option 
 SELECT TOP 1 emp2.FirstName,
        emp2.LastName,
        emp2.Salary 
  FROM (SELECT DISTINCT TOP 3 emp.FirstName,
                              emp.LastName,
                              emp.Salary 
                         FROM Employees emp
                     ORDER BY emp.Salary DESC) AS emp2
ORDER BY Salary
 -- third option - but this time we will take 7-th highest salary BUT the second person with 7th highest salary 
 -- could be done with "WITH" or VIEW - i will demonstrate both cases
 WITH mid_result
 AS
 (
  SELECT TOP 10 emp.FirstName,  
         emp.LastName,
         emp.Salary,
         DENSE_RANK() OVER (ORDER BY emp.salary DESC) 'dense rank'
      FROM Employees emp
  ORDER BY emp.Salary DESC
 )
 
  SELECT tbl2.FirstName,
         tbl2.LastName,
         tbl2.Salary 
    FROM (SELECT tbl.FirstName,
                 tbl.LastName,
                 tbl.Salary,
                 ROW_NUMBER() OVER(ORDER BY salary) [ROWS] 
            FROM (SELECT * 
                    FROM mid_result 
                   WHERE [dense rank] = 7) tbl) tbl2
                   WHERE [rows] = 2
  
-- done with VIEW
go
SELECT tbl2.FirstName,
     tbl2.LastName,
       tbl2.Salary 
 FROM cte_mid_result_external tbl2
 WHERE [row_number] = 2




 -- with the first internal view we use dense rank and order the querie by salary in desc 
 go
create or alter view cte_mid_result_internal
AS
(
  SELECT emp.FirstName,  
         emp.LastName,
         emp.Salary,
         DENSE_RANK() OVER (ORDER BY emp.salary DESC) 'salary_rank'
    FROM Employees emp
 )
 go
 -- with the external view we get the row numbers of particular salary rank 
create or alter view cte_mid_result_external
as
(
SELECT  tbl.FirstName,
        tbl.LastName,
        tbl.Salary,
        ROW_NUMBER() OVER(ORDER BY salary) [row_number] 
  FROM (SELECT * 
          FROM cte_mid_result_internal 
          WHERE salary_rank = 7)tbl
)

  




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             002
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                                -- HOW TO take all managers of particular employee
  -- first option just shows each employee with his manager 
  select * from Employees
  GO 
  
   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID,
          m.FirstName,
          m.LastName,
          ISNULL(CAST('ManagerId: '+ cast(m.ManagerID as nvarchar(max)) +': '+ m.FirstName +' '+ m.LastName AS NVARCHAR(max)), 
          'This employee does not have manager') as 'Manager Info'
     FROM Employees    AS e
     JOIN Employees    AS m ON m.EmployeeID = e.ManagerID
 ORDER BY e.EmployeeID
    

GO
  -- second option shows all managers of certain employee 
GO
 DECLARE @employee_id INT  SET @employee_id = 66;

WITH emp_cte
AS
(
-- recursive CTE has 2 members 
-- first one is ANCHOR
   SELECT emp.EmployeeID,
          emp.FirstName,
          emp.LastName,
          emp.ManagerID     
     FROM Employees emp
    WHERE emp.EmployeeID = @employee_id
    UNION ALL 
  -- second one is recursive member
   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e  
     JOIN emp_cte cte ON e.EmployeeID = cte.ManagerID -- usually i use the oposite syntax but for the recursive CTE is easier to understand
     -- in this way because Anchor part is used as input param for recurive member: e.EmployeeID = cte.ManagerID = 16
     -- it is 16 because employeeID = 1 has managerId equal to 16
)

  --SELECT emp_table.EmployeeID,
  --        emp_table.FirstName,
  --        emp_table.LastName
  --   FROM emp_cte emp_table
    

   SELECT emp_table.EmployeeID,
          emp_table.FirstName,
          emp_table.LastName,
          ISNULL(mngr_table.FirstName +' '+ mngr_table.LastName,'no Boss') AS 'manager' 
     FROM emp_cte emp_table
    left JOIN emp_cte mngr_table ON mngr_table.EmployeeID = emp_table.ManagerID

-- further down i will break line by line how this recursive cte works
-- step 1 -- execute first select statement ANCHOR and we take manager id == 16 to step 2
-- because we use it as input param to the recursive member
SELECT emp.EmployeeID,
       emp.FirstName,
       emp.LastName,
       emp.ManagerID     
  FROM Employees emp
 WHERE emp.EmployeeID = 1
-- this is the result set:
-- 1  Guy  Gilbert  16 -- and this is used as input for the resursive member

-- step 2 - execute second select statement RECURSIVE MEMBER without join just with where clause and managerID == 16
   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e
     --JOIN emp_cte cte ON cte.ManagerID = e.EmployeeID
     where e.EmployeeID = 16 -- = cte.ManagerID

-- this is the result set:
-- 16  Jo  Brown  21 and each result set is attach to the final result set when managerId get null.This is when UNION ALL is applied

-- step 3 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e
     where e.EmployeeID = 21

-- this is the result set:
-- 21  Peter  Krebs  148

-- step 4 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e
     where e.EmployeeID = 148

-- this is the result set:
-- 148  James  Hamilton  109

-- step 5 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e
     where e.EmployeeID = 109

-- this is the result set:
-- 109  Ken  Sanches  null , and here the recursive cte stops 

-- third option will rank the hierarchy starting from top to the bottom

GO
WITH rank_cte(EmployeeID, FirstName, LastName, ManagerID, [Level])
    AS
    (
  
   SELECT emp.EmployeeID,
          emp.FirstName,
          emp.LastName,
          emp.ManagerID,
          1   
     FROM Employees emp
    WHERE emp.ManagerID is NULL
UNION ALL 
   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID,
          cte.[level] + 1
     FROM Employees e
     JOIN rank_cte cte ON cte.EmployeeID = e.ManagerID
    )

    --select * from rank_cte
    --order by rank_cte.level


    select employees.EmployeeID,
           employees.FirstName,
           employees.LastName,
           ISNULL(cast(employees.ManagerID as nvarchar(50)),'he is his own boss')AS manager_id, 
           ISNULL(managers.FirstName, 'Boss') AS Manager,
           employees.level
      from rank_cte employees
 left join rank_cte managers ON managers.EmployeeID = employees.ManagerID

 -- done with stored procedure
 exec spe_get_all_managers_by_certain_employee @i_employee_id = 3
 
 go
 create or alter procedure spe_get_all_managers_by_certain_employee
 (
 @i_employee_id int
 )
 as
 begin

DECLARE @employee_id INT  SET @employee_id = @i_employee_id;

WITH emp_cte
AS
(

   SELECT emp.EmployeeID,
          emp.FirstName,
          emp.LastName,
          emp.ManagerID     
     FROM Employees emp
    WHERE emp.EmployeeID = @employee_id
    UNION ALL 
  
   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          e.ManagerID 
     FROM Employees e  
     JOIN emp_cte cte ON e.EmployeeID = cte.ManagerID 
)

   SELECT emp_table.EmployeeID,
          emp_table.FirstName,
          emp_table.LastName,
          ISNULL(mngr_table.FirstName +' '+ mngr_table.LastName,'no Boss') AS 'manager' 
     FROM emp_cte emp_table
    left JOIN emp_cte mngr_table ON mngr_table.EmployeeID = emp_table.ManagerID
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             003
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO delete dublicate rows
go



CREATE TABLE Employees_test_table
(
ID INT,
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Gender NVARCHAR(50),
Salary INT  
)
INSERT INTO Employees_test_table 
VALUES 
(1,'petko','petkov','man',5000),
(1,'petko','petkov','man',5000),
(2,'ivan','petkov','man',7000),
(2,'ivan','petkov','man',7000),
(3,'georgi','petkov','man',6000),
(3,'georgi','petkov','man',6000),
(3,'georgi','petkov','man',6000),
(4,'jeko','petkov','man',1000),
(4,'jeko','petkov','man',1000)

WITH emp_cte
as
(
SELECT e.ID,
       e.FirstName,
       ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) 'row number'
  FROM Employees_test_table e
)
DELETE  
  FROM emp_cte 
 WHERE [row number] > 1

 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             004
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find employees hired in last N-th month
-- in my case i will use years because my table data is little bit older

SELECT * 
  FROM (SELECT e.FirstName,
               e.LastName,
               DATEDIFF(YEAR,HireDate,GETDATE()) AS 'date diffrence in months' 
          FROM Employees e) emp
 WHERE [date diffrence in months] < 15


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             005
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find department with highest number of employees
USE SoftUni

  SELECT TOP 1 D.[Name],
         COUNT(*) 'people per department' 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
GROUP BY d.[Name]
ORDER BY COUNT(*) DESC







-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             006
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find count of people grouped by departent and town name using 
                                                            -- 3 join statements  


  SELECT d.[Name],
         t.[Name],
         COUNT(*) AS 'count of people'
    FROM Employees e
    JOIN Departments d  ON d.DepartmentID = e.DepartmentID
    JOIN Addresses a    ON a.AddressID = e.AddressID
    JOIN Towns t        ON t.TownID = a.TownID 
GROUP BY d.[Name],t.[Name]
ORDER BY COUNT(*) DESC








-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             007
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find all names that start with certain letter without like operator

USE SoftUni
-- this is the first option but because of the point of this task i will show other 2 different ways how to be done
SELECT * FROM Employees WHERE FirstName like 'm%'

SELECT * FROM Employees WHERE CHARINDEX('m',FirstName) = 1;
SELECT * FROM Employees WHERE LEFT(FirstName,1) = 'm';
SELECT * FROM Employees WHERE SUBSTRING(FirstName,1,1) = 'm'


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             008
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO insert into many to many table

-- purposely i did not created composite primary key to show what is going to happend when we insert same data into StudentCourses table which is 
-- mapping table and has student id and course id.
-- the result will be dublicated rows and that's why we need composite key
GO
use student_test_db

GO
SELECT * FROM Students
SELECT * FROM Courses
SELECT * FROM StudentCourses

delete from Students
delete from Courses
delete from StudentCourses


DECLARE @student_name NVARCHAR(50) SET @student_name = 'test_student_5'
DECLARE @course_name NVARCHAR(50)  SET @course_name = 'test_course_5'

DECLARE @student_id INT
DECLARE @course_id INT

SELECT @student_id = id 
  FROM Students 
 WHERE @student_name = student_name


 SELECT @course_id = id 
   FROM Courses
  WHERE @course_name = course_name 



IF(@student_id is null)
BEGIN
  INSERT INTO students VALUES(@student_name)
  SELECT @student_id = SCOPE_IDENTITY()
  print @student_id
END

IF(@course_id is null)
BEGIN
  INSERT INTO Courses VALUES(@course_name)
  SELECT @course_id = SCOPE_IDENTITY()
  print @student_id
END

insert into StudentCourses 
values 
(@student_id,@course_id)

-- now after the result it is quite obvious i will alter the table and will create composite primary key but before that 
-- because we will have dublicated rows we have to delete them from the records of the table
DELETE FROM StudentCourses WHERE student_id = 2 and course_id = 2 -- just for an example

ALTER TABLE StudentCourses 
ADD CONSTRAINT  PK_StudentCourses PRIMARY KEY CLUSTERED(student_id,course_id)

-- and because the right way to be done is by adding this script to store procedure i will do it in this way 
GO
CREATE OR ALTER PROCEDURE sp_insert_into_student_courses

@student_name NVARCHAR(50), 
@course_name NVARCHAR(50)  
AS
BEGIN

DECLARE @student_id INT
DECLARE @course_id  INT

SELECT @student_id = id 
  FROM Students 
 WHERE student_name = @student_name

 SELECT @course_id = id 
   FROM Courses
  WHERE course_name = @course_name

IF(@student_id is null)
BEGIN
  INSERT INTO students VALUES(@student_name)
  SELECT @student_id = SCOPE_IDENTITY()
END

IF(@course_id is null)
BEGIN
  INSERT INTO Courses VALUES(@course_name)
  SELECT @course_id = SCOPE_IDENTITY()
END

INSERT INTO StudentCourses VALUES (@student_id,@course_id)

END

EXEC sp_insert_into_student_courses 'PETKO', 'C#'
SELECT * FROM StudentCourses

SELECT * FROM Students
SELECT * FROM Courses
SELECT * FROM StudentCourses
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             009
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO get people after, before or between certain date

GO
USE SoftUni

SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE CAST(e.HireDate AS DATE) >= '2000-04-29'

SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE e.HireDate >= '2000-04-29'


SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE CAST(e.HireDate AS DATE) BETWEEN '2000-04-29' AND '2002-04-29' 

SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE Day(e.HireDate) BETWEEN '1' AND '2' 

SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE Day(e.HireDate) = 2 AND MONTH(e.HireDate) = 1


SELECT e.FirstName,
       e.LastName,
       CAST(e.HireDate AS DATE)  hire_date
  FROM Employees e
 WHERE cast(e.HireDate as date) < DATEADD(year,-17,cast(GETDATE() as date))

 
select DATEADD(DAY, 5, cast(getdate() as date))

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             010
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO insert full list of records from one table to another and adding
                                                            -- additional empthy columns                                                            

  SELECT EmployeeID,
         FirstName,
         LastName,
         Salary,
         NULL AS NextSalary,
         ROW_NUMBER() OVER (ORDER BY employeeID) row_num
    INTO #tempEmp
    FROM Employees 

    select * from #tempEmp



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             011
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  -- How to:
  -- get the products without any sales
  -- get products and their sold quantities
  -- generate random numbers
  -- how to use STUFF with FOR XML PATH with example:
  use student_test_db

 create table products_test
(
 [Id] int identity primary key,
 [Name] nvarchar(50),
 [Description] nvarchar(250)
)

create Table product_sales_test
(
 Id int primary key identity,
 product_id int foreign key references products_test(Id),
 unit_price int,
 quantity_sold int
)

Insert into products_test values ('TV', '52 inch black color LCD TV')
Insert into products_test values ('Laptop', 'Very thin black color acer laptop')
Insert into products_test values ('Desktop', 'HP high performance desktop')

Insert into product_sales_test values(3, 450, 5)
Insert into product_sales_test values(2, 250, 7)
Insert into product_sales_test values(3, 450, 4)
Insert into product_sales_test values(3, 450, 9)

select * from products_test
select * from product_sales_test order by Id

-- get the products without any sales

-- first option--------
  select pt.id, pt.Name, pt.Description
    from products_test pt
    left join product_sales_test pst
      on pt.Id = pst.product_id
group by pt.id, pt.Name, pt.Description
  having count(pst.product_id) < 1
  order by pt.Name

-- second option--------
  select pt.id, pt.Name, pt.Description
    from products_test pt
    left join product_sales_test pst
      on pt.Id = pst.product_id
   where isnull(pst.product_id, 0 ) = 0
   order by pt.Name
   -----------------------
   select pt.Id, 
          pt.Name, 
          pt.Description
     from products_test pt
left join product_sales_test pst on pst.product_id = pt.Id
     where pst.product_id is null


-- third option-------
select pt.Id, 
       pt.Name, 
       pt.Description 
  from products_test pt
 where pt.Id not in (select distinct pst.product_id 
                       from product_sales_test pst)
 order by pt.Name
-- fourth option------
select pt.id, 
         pt.Name, 
         pt.Description from products_test pt
   where not exists(select * 
                      from product_sales_test pst 
                     where pst.product_id = pt.Id)
   order by pt.Name


   
-- get products and their sold quantities
    select pt.Name,sold_quantity
      from products_test pt
 left join (select product_id,
                   sum(pst.quantity_sold)  as sold_quantity 
              from product_sales_test pst
          group by product_id)               as quoral
        on pt.Id = quoral.product_id


    select pt.Name,
           (select sum(pst.quantity_sold) 
              from product_sales_test pst 
             where pst.product_id = pt.Id) as sold_quantity 
      from products_test pt

  
  -- drop tables

  if (exists (select * 
                from INFORMATION_SCHEMA.TABLES
               where TABLE_NAME = 'products_test'))
    begin
        drop table products_test
    end


    if (exists (select * 
                from INFORMATION_SCHEMA.TABLES
               where TABLE_NAME = 'product_sales_test'))
    begin
        drop table product_sales_test
    end

create table products_test
(
  [Id] int identity primary key,
  [Name] nvarchar(MAX),
  [Description] nvarchar(MAX)
)

create Table product_sales_test
(
 Id int primary key identity,
 product_id int foreign key references products_test(Id),
 unit_price int,
 quantity_sold int
)
      
declare @id int  set @id = 1

while (@id < 300000)
begin
  insert into products_test
  values
  ('Product - ' + CAST(@Id as nvarchar(20)), 
   'Product - ' + CAST(@Id as nvarchar(20)) + ' Description')
  Print @Id
    Set @Id = @Id + 1
end

select * from products_test


-- Declare variables to hold a random ProductId, 
-- UnitPrice and QuantitySold
declare @random_product_Id int
declare @random_unit_price int
declare @random_quantity_sold int

-- Declare and set variables to generate a 
-- random ProductId between 1 and 100000
declare @lower_limit_for_product_id int         set @lower_limit_for_product_id = 1  
declare @upper_limit_for_product_Id int         set @upper_limit_for_product_Id = 100000


-- Declare and set variables to generate a 
-- random UnitPrice between 1 and 100
declare @lower_limit_for_unit_price int         set @lower_limit_for_unit_price = 1
declare @upper_limit_for_unit_price int         set @upper_limit_for_unit_price = 100


-- Declare and set variables to generate a 
-- random QuantitySold between 1 and 10
declare @lower_limit_for_quantity_sold int      set @lower_limit_for_quantity_sold = 1                                                       
declare @upper_limit_for_quantity_sold int      set @upper_limit_for_quantity_sold = 10



--Insert Sample data into tblProductSales table
Declare @Counter int
Set @Counter = 1

While(@Counter <= 300000)
Begin
                                       
 select @random_product_Id    = Round(((@upper_limit_for_product_Id - @lower_limit_for_product_id) * Rand() + @lower_limit_for_product_id), 0)
 select @random_unit_price    = Round(((@upper_limit_for_unit_price - @lower_limit_for_unit_price) * Rand() + @lower_limit_for_unit_price), 0)
 select @random_quantity_sold = Round(((@upper_limit_for_quantity_sold - @lower_limit_for_quantity_sold) * Rand() + @lower_limit_for_quantity_sold), 0)
 
 Insert into product_sales_test 
 values(@random_product_Id, @random_unit_price, @random_quantity_sold)

 Print @Counter
 Set @Counter = @Counter + 1
End



-- demonstration how random gerator number works
declare @test int set @test = 1
declare @testUp int set @testUp = 10

--select ROUND((@testUp - @test) * rand() + @test, 0)

declare @random int
while (1=1)
begin
    select @random = ROUND((@testUp - @test) * rand() + @test, 0)
    print @random
    if(@random < 1 or @random > 10)
    begin
      print 'error' + cast(@random as nvarchar(max))
      break
    end
    
end




select * from products_test
select * from product_sales_test pst order by Id

select pt.Id, 
       pt.Name, 
       pt.Description 
  from products_test pt
 where pt.Id in (select pst.product_id 
                   from product_sales_test pst)

 select distinct pt.id, 
        pt.Name, 
        pt.Description 
   from products_test pt
   join product_sales_test pst on pst.product_id = pt.Id


   checkpoint ;
   go
   dbcc dropcleanbuffers -- clear query cache
   go
   dbcc freeproccache -- clear execution plan cache
   go


select * from product_sales_test pst where pst.product_id = 99000 
select * from products_test
DECLARE @id INT
select @id = pt.id from products_test pt where pt.id = 33
print @id


select * from products_test
select * from product_sales_test pst order by product_id

-- ---------------------------------------------------------------------

with cte_test
 as
 (
  SELECT pt.ID, 
         STUFF((SELECT ', ' + CAST(pst.unit_price AS varchar(10))
                  FROM product_sales_test AS pst  
                 WHERE pst.product_id = pt.ID 
                   AND (pst.unit_price < 10  OR (pst.unit_price > 10 AND pst.unit_price <= 50))
                   FOR XML PATH('')),1,1,'') AS Ids
    FROM products_test AS pt
GROUP BY pt.ID
)

update products_test
   set Name = CONCAT(pt.[Name],  cast (ct.Ids AS NVARCHAR(2048)))
   from products_test pt
  join cte_test ct on ct.Id = pt.Id 
  where Ids is not null

select * from products_test
select * from product_sales_test pst order by Id
select max(product_id) from product_sales_test




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             012
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT * FROM SYSOBJECTS WHERE xtype = 'u'
SELECT * FROM SYS.tables
select * from INFORMATION_SCHEMA.TABLES

if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'employees' and TABLE_SCHEMA = 'dbo')
begin
 print ' not exist'
end
else

begin
  print 'exist'
end

-- how to get the number of the columns 
SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE table_catalog = 'SoftUni' -- the database
   and TABLE_SCHEMA = 'dbo'
   AND table_name = 'Employees'


-- how to get primary key of table
SELECT * FROM sys.objects
    WHERE type = 'PK' 
    AND  parent_object_id = OBJECT_ID ('[dbo].Employees')
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             013
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- how to group by different criteria in one table 


select t.Name, 
       d.Name, 
       sum(e.Salary) as total_salary 
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  join Addresses a   on a.AddressID = e.AddressID
  join Towns t       on t.TownID = a.TownID
group by grouping sets
(
  (t.Name, d.Name),
  (t.name),
  () -- by total_salary 
)
order by grouping(t.name), GROUPING(d.Name)


-- done with union all ---------------------------------------------------------

select t.name, d.Name, sum(e.Salary) as total_salary 
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  join Addresses a   on a.AddressID = e.AddressID
  join Towns t       on t.TownID = a.TownID
group by t.name ,d.Name
         
union all

select t.Name,null, sum(e.Salary) as salary 
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  join Addresses a   on a.AddressID = e.AddressID
  join Towns t       on t.TownID = a.TownID
group by t.Name

union all

select null,null,sum(e.Salary) from Employees e 

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             014
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 
-- same result set but different performance
select distinct d.Name, 
       sum(e.Salary) over (partition by name) total_salary
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID


    select d.Name, 
           sum(e.Salary) total_salary
      from Employees e
      join Departments d on d.DepartmentID = e.DepartmentID
  group by d.Name


  -- ----------------------------------------------------------
  select e.FirstName, 
         e.LastName, 
         e.Salary,
         average,
         minimum,
         maximum
    from Employees e
    join (select e.DepartmentID,
                 AVG(e.Salary) average, 
                 min(e.Salary) minimum, 
                 max(e.Salary) maximum 
            from Employees e
        group by e.DepartmentID) emp on emp.DepartmentID = e.DepartmentID 




      select e.FirstName,
             e.LastName,
             e.Salary,
             d.[Name],
             AVG(e.Salary) OVER(PARTITION BY e.DepartmentId) average,
             min(e.Salary) OVER(PARTITION BY e.DepartmentId) minimum,
             max(e.Salary) OVER(PARTITION BY e.DepartmentId) maximum,
             ROW_NUMBER()  OVER(PARTITION BY e.DepartmentId order by salary) [row_number],
             RANK()        OVER(PARTITION BY e.departmentId order by salary) rank_column_with_partition,
             DENSE_RANK()  OVER(PARTITION BY e.departmentId order by salary) dense_rank_column_with_partition,
             RANK()        OVER( ORDER BY salary) rank_column_without_partition,
             DENSE_RANK()  OVER( ORDER BY salary) dense_rank_column_without_partition
        from Employees e
        join Departments d on d.DepartmentID = e.DepartmentID



select e.FirstName,
       e.LastName,
       e.salary,
       ROW_NUMBER()  OVER (order by salary) [row_number],
       RANK()        OVER (order by salary) rank_column_with_partition,
       DENSE_RANK()  OVER (order by salary) dense_rank_column_with_partition
  from Employees e


 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             015
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- how to get running total value as additional column


select e.FirstName, 
       e.LastName,
       e.Salary,
       sum(e.salary) over (order by e.employeeId)
  from Employees e

go



-- the same result with cursor

drop table #tempEmp
  SELECT EmployeeID,
         FirstName,
         LastName,
         Salary,
         0 AS running_total_salary,
         ROW_NUMBER() OVER (ORDER BY employeeID) row_num
    INTO #tempEmp
    FROM Employees 

    
SELECT * FROM #tempEmp


DECLARE @Salary INT;
DECLARE @row_num BIGINT;
DECLARE @temp_salary int SET @temp_salary = 0

  DECLARE total_result_c CURSOR FOR 
   SELECT Salary, 
          row_num
     FROM #tempEmp 
 ORDER BY employeeID
OPEN total_result_c
  FETCH NEXT FROM total_result_c INTO  @Salary, @row_num;
  PRINT @Salary;
  PRINT @row_num;
  WHILE @@FETCH_STATUS <> -1
  BEGIN
    
    set @temp_salary +=@Salary 
    
    update #tempEmp
       set running_total_salary += @temp_salary
     where row_num = @row_num
     
    -- set @temp_salary = (select running_total_salary 
    --                       from #tempEmp 
    --                      where row_num = @row_num)
    --PRINT @temp_salary
    
    FETCH NEXT FROM total_result_c INTO  @Salary, @row_num
  END
CLOSE total_result_c
DEALLOCATE total_result_c

select * from #tempEmp




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             016
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--  HOW TO check for dependency in any sp
  
-- this is how we can get all dependencies  or just right click from object explorer on particular object

select * from sys.dm_sql_referencing_entities('dbo.Employees','Object')
select * from sys.dm_sql_referenced_entities('dbo.cte__custom_table_rows','Object')

select * from cte__custom_table_rows


exec sp_depends 'employees'

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                            017
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- how to set increment value

create sequence dbo.sequence_object
as INT
START WITH 1
INCREMENT BY 1

alter sequence sequence_object
restart with 1



SELECT * FROM SYS.sequences WHERE NAME = 'sequence_object'

SELECT NEXT VALUE FOR dbo.sequence_object





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             018
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- how to insert the data from 2 tables into third table using guid



create table Customer_V
(
  ID uniqueidentifier primary key default newid(),
  Name nvarchar(50)
)

create table Customer_V_2
(
  ID uniqueidentifier primary key default newid(),
  Name nvarchar(50)
)

create table Customer_all_in_one
(
  ID uniqueidentifier primary key default newid(),
  Name nvarchar(50)
)


insert into Customer_all_in_one
select * from Customer_V
union all 
select * from Customer_V_2

insert into Customer_V
values
(default, 'gosho'),
(default, 'kaloyan')

insert into Customer_V_2
values
(default, 'minko'),
(default, 'evgeni')

select * from Customer_V
select * from Customer_V_2
select * from Customer_all_in_one
-- how to cast 
select cast(cast(0 as binary) as uniqueidentifier)

delete from Customer_V
delete from Customer_V_2
delete from Customer_all_in_one


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                            019
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- HOW TO  use cross apply 

-- cross apply = inner join 
-- outer apply = left join 

-- querie plan cache - hashed value 

select d.Name,
       e.FirstName, 
       e.LastName, 
       e.Salary
  from Departments d
  left join Employees e on e.DepartmentID = d.DepartmentID

go
     select d.Name,
            e.employeeId,
            e.FirstName, 
            e.LastName, 
            e.Salary
       from Departments d
cross apply fn_getemployeesbydepartmentid(d.DepartmentID) e 

go
create or alter function fn_getemployeesbydepartmentid(@DepartmentId int)
returns table
as
return
(
 select *
 from Employees e
 where e.DepartmentID = @DepartmentId
)
go

SELECT * FROM Employees

     SELECT cp.usecounts, 
            cp.cacheobjtype, 
            cp.objtype, 
            st.text, 
            qp.query_plan
       FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
   ORDER BY cp.usecounts DESC

dbcc freeproccache

-- in querie cache plan the change of the parameter name  does no affect it 
declare @firstname nvarchar(50)
set @firstname = 'guy'
execute sp_executesql N'select * from employees where firstname=@fn', N'@fn nvarchar(50)', @firstname

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                   020    
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--HOW TO get count of emp by certain criteria on each row with other columns

    select e.FirstName,
           e.LastName,
           count(*) over ()
      from Employees e
      where Salary > 40000

-- ------------------------------------------------
      select e.FirstName,
         e.LastName,
         (select COUNT(*) count_of_people_with_same_salary
            from Employees e0 
           where e0.Salary > 40000)
    from Employees e    
   where e.Salary > 40000

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                     021        
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- HOW TO get only UNmatching record from 2 tables
-- version one
select t.table_one_code as table_one_code_from_table_table_one
  from table_one t
  full join table_two t2 on t2.table_one_code = t.table_one_code
  where t1.table_one_code is null
   
 -- version two
   SELECT t.table_one_code
      FROM table_one t
     WHERE NOT EXISTS(SELECT 1 
                        FROM table_two 
                       WHERE table_two_code = t.table_one_code)

SELECT t1.ID,
       t1.NAME 
  FROM #TABLE1 t1
  WHERE t1.ID NOT IN (SELECT T1.ID
                        from #TABLE1 t1
                        join #TABLE2 t2 on t2.ID = t1.ID)

SELECT t1.ID,
       t1.NAME 
  FROM #TABLE1 t1
  WHERE t1.ID NOT IN (SELECT T1.ID
                   from #TABLE2 t2
                   where t2.ID = t1.id)       
                   
SELECT t1.ID,
       t1.NAME 
  FROM #TABLE1 t1
  WHERE NOT EXISTS (SELECT 1
                      from #TABLE2 t2
                     where t2.ID = t1.id)       




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                              022               
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- find employee which name is.. michael - does not matter it is being writter: MIchael, Michael, MICHAEL OR...

USE SoftUni
SELECT * 
  FROM Employees e 
 WHERE LOWER(e.FirstName) LIKE '%michael%'

  SELECT FirstName, COUNT(FirstName)
    FROM Employees
GROUP BY FirstName
ORDER BY COUNT(FirstName) DESC

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                023             
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @v_exists INT; SET @v_exists = 0;
DECLARE @o_active BIT; SET @o_active = 0; 

select @v_exists = 1, @o_active = 1 
  from Employees e 
 where e.FirstName = 'guy'

  print @v_exists
  print @o_active

   
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  024           
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CREATE TABLE #TABLE1 (
ID INT,
NAME NVARCHAR(30)
)

CREATE TABLE #TABLE2 (
ID INT,
NAME NVARCHAR(30)
)

INSERT INTO #TABLE1 (ID,NAME) VALUES 
(1,'ONE'),
(2,'TWO'),
(3,'THREE'),
(4,'different')


INSERT INTO #TABLE2 (ID,NAME) VALUES 
(1,'ONE'),
(2,'TWO'),
(3,'THREE')
--(4,'different')

SELECT t1.ID,
       t1.NAME 
  FROM #TABLE1 t1
  WHERE t1.ID NOT IN (SELECT T1.ID
                        from #TABLE2 t2
                      where t2.ID = t1.id)                         

SELECT ID,NAME FROM #TABLE1 
EXCEPT
SELECT ID,NAME FROM #TABLE2 


SELECT
CASE WHEN @@ROWCOUNT = 0
	THEN '1 - THEY ARE SAME!!'
	ELSE '0 - NOPE THEY ARE DIFFERENT !!'
END 	

DROP TABLE #TABLE1
DROP TABLE #TABLE2

-- comparing EXCEPT and BETWEEN 

SELECT e.FirstName,
       e.LastName,
       e.Salary 
  FROM Employees e
 WHERE e.Salary > 50000
EXCEPT
 SELECT e.FirstName,
       e.LastName,
       e.Salary 
  FROM Employees e
 WHERE e.Salary > 100000
order by e.Salary,e.FirstName asc

 SELECT e.FirstName,
       e.LastName,
       e.Salary 
  FROM Employees e
 WHERE e.Salary between 50000 and 100000
 order by e.Salary, e.FirstName asc

-- -------------------------------------------------------------------------------------

DECLARE @table_one  int select @table_one = count(*) from #table1 
DECLARE @table_two  int select @table_two = count(*) from #table2 

declare @equal nvarchar(10)
if @table_one = @table_two
  begin
    set @equal = 'yes'
  end
else
  begin
    set @equal = 'no'  
  end

SELECT * FROM #TABLE1
EXCEPT 
SELECT * FROM #TABLE2

select case when @@ROWCOUNT = 0 and @equal = 'yes'
THEN '1 - THEY ARE SAME!!'
ELSE '0 - NOPE THEY ARE DIFFERENT !!'
end

-- -------------------------------------------------------------------------------------
SELECT t1.Id,
       t1.[name]
  FROM #TABLE1 t1
 WHERE NOT EXISTS (SELECT t2.id,
                          t2.[name]
                     FROM #TABLE2 t2
                    WHERE t1.id = t2.id 
                      AND t1.[name] = t2.[name])
GROUP BY t1.id, t1.[name]

SELECT
CASE WHEN @@ROWCOUNT = 0
	THEN '1 - THEY ARE SAME!!'
	ELSE '0 - NOPE THEY ARE DIFFERENT !!'
END 	

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  025
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- The EXISTS operator returns true if the subquery returns one or more records.
  go
  CREATE OR ALTER PROCEDURE spe_test_proc
  (@i_table_input_value nvarchar(50))
  AS
  BEGIN
    CREATE TABLE #temp_table_example ([name] NVARCHAR(50))
    INSERT INTO #temp_table_example 
    VALUES (@i_table_input_value)
  
    IF (OBJECT_ID('tempdb..#temp_table_example')) IS NOT NULL
      BEGIN
        SELECT 'Table exist' AS temp
        -- if NOT EXIST returns TRUE (which means that there is no record into #temp_table_example) then we get in IF statement
          IF ( NOT EXISTS  (SELECT 1 FROM #temp_table_example)) 
            BEGIN
              SELECT 'table is empthy!' AS temp
            END
          ELSE
            BEGIN
              SELECT * FROM #temp_table_example
            END
      END
    ELSE 
      BEGIN
        SELECT 'table does not exist!' AS temp
      END
  END

      exec spe_test_proc 'petko petkov'
      SELECT * FROM #temp_table_example


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  025
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
select * from Employees
begin tran
UPDATE Employees SET Salary = 43301 WHERE EmployeeID = 1
begin tran
UPDATE Employees SET Salary = 13003 WHERE EmployeeID = 3

rollback


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  026
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

select * from Employees_test_table

GO
CREATE OR ALTER PROCEDURE usp_delete_bulk
AS
BEGIN
  DECLARE @stop               INT                   SET @stop = 0
  DECLARE @rowAffected        INT                   
  DECLARE @totalRowAffected   INT                   SET @totalRowAffected = 0 

  WHILE @stop=0
      BEGIN
          DELETE TOP (4)
          FROM    A 
          FROM    [Employees_test_table] AS A
                  INNER JOIN ( SELECT [e].[Id]
                                 FROM [Employees_test_table] AS [e]
                                WHERE [e].[Salary] > 1000) AS B ON A.[Id] = B.[Id]
          SET @rowAffected = @@ROWCOUNT
          SET @totalRowAffected += @rowAffected
  
          IF @rowAffected = 4
            BEGIN
              SET @stop = 1
            END
      END
      select @rowAffected
      select @totalRowAffected
END
SELECT * FROM Employees_test_table
BEGIN TRAN
EXEC usp_delete_bulk
ROLLBACK
select @@trancount



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  027
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

USE UserInfo


GO
CREATE OR ALTER PROCEDURE spe_update_random_salary
@i_initial_salary INT 
AS
BEGIN
DECLARE @v_id_number             INT         SET @v_id_number = 0
DECLARE @v_actual_salary         INT         SET @v_actual_salary = 0
DECLARE @v_random_salary         INT         SET @v_random_salary = 0

DECLARE TestCursor CURSOR FOR 
 SELECT uit.Id,
        uit.Salary
   FROM UserInfoTable uit 

OPEN TestCursor
  FETCH NEXT FROM TestCursor INTO @v_id_number, @v_actual_salary

  WHILE @@FETCH_STATUS <> -1
  BEGIN
  
       SET @v_random_salary = round((@i_initial_salary * rand() * @v_actual_salary),0)
    UPDATE UserInfoTable
       SET Salary = @v_random_salary
     WHERE Id = @v_id_number
    FETCH NEXT FROM TestCursor INTO @v_id_number,@v_actual_salary
    
  END
CLOSE TestCursor
DEALLOCATE TestCursor
END

select * from UserInfoTable

exec spe_update_random_salary 44


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  028
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


select is_read_committed_snapshot_on, *
from sys.databases
DBCC useroptions

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  029
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use SoftUni

-- demonstrate diffrent syntax of insert into table
create table example_one_table
(
first_name nvarchar(50),
last_name nvarchar(50),
age int default 0,
salary numeric(16,10) default 0.00,
)

INSERT into example_one_table(first_name,last_name)
values
('petko','petkov')

declare @fistname nvarchar(50) set @fistname = 'petko1'
declare @lastname nvarchar(50) set @lastname = 'petkov2'
INSERT 
  into example_one_table(first_name,last_name) 
select @fistname,@lastname

insert
  into example_one_table (first_name,last_name)
  select 'test','testov'

insert
  into example_one_table(first_name, last_name)
  select top 10 e.FirstName,e.LastName from Employees e

insert
  into example_one_table
  select top 10 e.FirstName,e.LastName, null, null from Employees e

select * from example_one_table

insert 
  into example_one_table
select 'test_1','testOFF_1',22,1000 union all
select 'test_2','testOFF_2',44,3000 union all
select 'test_3','testOFF_3',33,5000

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  030
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select * 
  into copy_user_info_table 
  from userinfotable 
 where 1<>1
select * from copy_user_info_table


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  031
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- WHERE cannot be use? with aggregated function , HAVING can !
-- WHERE is used before group by and first filter the rows, unlike HAVING filtering rows after GROUP BY
select d.Name,sum(e.Salary) sum_salary_per_dep
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  where d.Name like 'p%'
  group by d.Name
  

  select d.Name,sum(e.Salary) sum_salary_per_dep
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  group by d.Name
  having d.Name like 'p%' 
  

  select d.Name,sum(e.Salary) sum_salary_per_dep
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  where d.Name like 'p%' 
  group by d.Name
  having SUM(e.Salary) > 50000

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  032
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select * into employees_copy from Employees

select * from employees_copy

create synonym employees_copy_synonym for employees_copy

select * from employees_copy_synonym
truncate table employees_copy_synonym

go
CREATE OR ALTER PROCEDURE dbo.spr_truncate_table_by_synonym_name 
(
  @schema_name AS sysname,
  @synonym_name AS sysname
)
AS 
BEGIN --Procedure
  SET NOCOUNT ON;

  DECLARE @base_object_name AS NVARCHAR(1035) = NULL;
  DECLARE @sql NVARCHAR(MAX);
  DECLARE @error_message NVARCHAR(255);

  SELECT TOP 1 @base_object_name = base_object_name
  FROM sys.synonyms
  INNER JOIN sys.schemas ON schemas.schema_id = synonyms.schema_id
  WHERE schemas.name = @schema_name
    AND synonyms.name = @synonym_name
    AND type = 'SN'
    AND is_ms_shipped = 0;

  IF @base_object_name IS NOT NULL
    BEGIN
      --SET @sql = N'TRUNCATE TABLE ' + @base_object_name;
      SET @sql = N'DELETE FROM ' + @base_object_name + ' WHERE SALARY < 100000';
        BEGIN TRY
          EXECUTE sys.sp_executesql @sql;
        
            IF OBJECT_ID('tempdb..#RowCount', 'U') IS NOT NULL
                DROP TABLE #RowCount;

            CREATE TABLE #RowCount ( return_value INT );

            SET @sql = N'INSERT INTO #RowCount SELECT Count(*) FROM ' + @schema_name + '.' + @synonym_name;
            EXECUTE sys.sp_executesql @sql;
        
            DECLARE @row_count INT = 0;
            SELECT TOP 1 @row_count = return_value
              FROM #RowCount;
            
            IF @row_count > 0
              BEGIN
                SET @error_message = 'The base table for synonym ' + @schema_name + '.' + @synonym_name + ' was not truncated.';
                RAISERROR(@error_message,16,1);
                END;
        END TRY
    
        BEGIN CATCH
            THROW;
        END CATCH;
    END;
ELSE
    BEGIN
        SET @error_message = 'The base table for synonym ' + @schema_name + '.' + @synonym_name + ' was not found.';
        THROW 50000,@error_message,1;
    END;
END;

begin tran
EXECUTE dbo.spr_truncate_table_by_synonym_name  @schema_name = 'dbo', @synonym_name = 'employees_copy_synonym'


select * from sys.synonyms
select * from employees_copy_synonym

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  033
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- all fourth approached are pretty simular, the only significant diffrence is when we are using the foreign key 
-- in group by clause  - it has better performance !!!

 -- first approach
select emp.department_name,
       salary_per_department 
  from (select d.Name as department_name,
               sum(e.Salary) salary_per_department
          from Employees e
          join Departments d on d.DepartmentID = e.DepartmentID
          group by d.name) as emp
  where salary_per_department > 100000
  order by salary_per_department

  -- second approach
  select d.Name,
         sum(e.Salary) as salary_per_department
    from Employees e
    join Departments d on d.DepartmentID = e.DepartmentID
   group by d.Name
   having sum(e.Salary) > 100000
   order by salary_per_department

   -- third approach

select emp.department_name,
       salary_per_department 
  from (select e.DepartmentID,
               d.Name as department_name,
               sum(e.Salary) salary_per_department
          from Employees e
          join Departments d on d.DepartmentID = e.DepartmentID
          group by d.name,e.DepartmentID) as emp
  where salary_per_department > 100000
  order by salary_per_department


  -- fourth approach
  select d.Name,
         sum(e.Salary) as salary_per_department
    from Employees e
    join Departments d on d.DepartmentID = e.DepartmentID
   group by d.Name,e.DepartmentID
   having sum(e.Salary) > 100000
   order by salary_per_department

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  034
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- how to add 'zero'0 to a nvarchar and to return it as nvarchar.
-- in the input we can have 193,;193.;193.0;193 - the final output always must be 193.{0}(one digit after the decimal point)
DECLARE @MyValue NVARCHAR(max)
SET @MyValue = '193.'
SELECT cast(CONVERT(decimal(10, 1), @MyValue) as nvarchar)

rollback
go
declare @MyValue nvarchar(max)
set @MyValue = '193,'
select REPLACE(REPLACE(CONVERT(NVARCHAR(10), CAST(REPLACE(@MyValue,',','.') AS DECIMAL(16,1)), 1),',',''),'.',',');

begin tran

select * from Employees


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  035
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- how to find open transactions in sql server

SELECT
trans.session_id AS [SESSION ID],
ESes.host_name AS [HOST NAME],login_name AS [Login NAME],
trans.transaction_id AS [TRANSACTION ID],
tas.name AS [TRANSACTION NAME],tas.transaction_begin_time AS [TRANSACTION 
BEGIN TIME],
tds.database_id AS [DATABASE ID],DBs.name AS [DATABASE NAME]
FROM sys.dm_tran_active_transactions tas
JOIN sys.dm_tran_session_transactions trans
ON (trans.transaction_id=tas.transaction_id)
LEFT OUTER JOIN sys.dm_tran_database_transactions tds
ON (tas.transaction_id = tds.transaction_id )
LEFT OUTER JOIN sys.databases AS DBs
ON tds.database_id = DBs.database_id
LEFT OUTER JOIN sys.dm_exec_sessions AS ESes
ON trans.session_id = ESes.session_id
WHERE ESes.session_id IS NOT NULL
