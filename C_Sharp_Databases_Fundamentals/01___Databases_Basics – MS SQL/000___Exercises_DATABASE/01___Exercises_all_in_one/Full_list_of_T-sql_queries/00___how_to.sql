

-- legend : 
--numbers $1 to $999 shows HOW TO do extract info from tables with queries
--numbers 001 to 1 shows other small hints and trics in SQL 


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $1
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
--                                                                             $2
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
 DECLARE @employee_id INT  SET @employee_id = 1;

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

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $3
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
--                                                                             $4
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
--                                                                             $5
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find department with highes number of employees
USE SoftUni

  SELECT TOP 1 D.[Name],
         COUNT(*) 'people per department' 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
GROUP BY d.[Name]
ORDER BY COUNT(*) DESC







-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $6
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
--                                                                             $7
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find all names that start with certain letter without like operator

USE SoftUni
-- this is the first option but because of the point of this task i will show other 2 different ways how to be done
SELECT * FROM Employees WHERE FirstName like 'm%'

SELECT * FROM Employees WHERE CHARINDEX('m',FirstName) = 1;
SELECT * FROM Employees WHERE LEFT(FirstName,1) = 'm';
SELECT * FROM Employees WHERE SUBSTRING(FirstName,1,1) = 'm'


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $8
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
 WHERE @student_name = student_name

 SELECT @course_id = id 
   FROM Courses
  WHERE @course_name = course_name 

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


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $9
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

 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $10
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
--                                                                             $11
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  -- How to:
  -- get the products without any sales
  -- get products and their sold quantities
  -- generate random numbers

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
select * from product_sales_test

-- get the products without any sales
  select pt.id, pt.Name, pt.Description
    from products_test pt
    left join product_sales_test pst
      on pt.Id = pst.product_id
group by pt.id, pt.Name, pt.Description
  having count(pst.product_id) < 1

  select pt.id, pt.Name, pt.Description
    from products_test pt
    left join product_sales_test pst
      on pt.Id = pst.product_id
   where isnull(pst.product_id, 0 ) = 0

      select  max(pst.product_id) from product_sales_test pst 

select pt.Id, 
       pt.Name, 
       pt.Description 
  from products_test pt
 where pt.Id not in (select distinct pst.product_id 
                        from product_sales_test pst)

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

    SELECT pt.Name, sum(pst.quantity_sold) as sold_quantities
      FROM products_test pt
 LEFT JOIN product_sales_test pst
        ON pt.Id = pst.product_id
  GROUP BY pt.Name
  ORDER BY sold_quantities


  -- performance testing

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
while (5=5)
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

select pt.Id, pt.Name, pt.Description 
  from products_test pt
 where pt.Id in (select pst.product_id from product_sales_test pst)

 select distinct pt.id, pt.Name, pt.Description 
   from products_test pt
   join product_sales_test pst on pst.product_id = pt.Id


   checkpoint ;
   go
   dbcc dropcleanbuffers -- clear query cache
   go
   dbcc freeproccache -- clear execution plan cache
   go

   select pt.id, pt.Name, pt.Description from products_test pt
   where not exists(select * from product_sales_test pst where pst.product_id = pt.Id)

   select pt.Id, pt.Name, pt.Description
     from products_test pt
left join product_sales_test pst on pst.product_id = pt.Id
     where pst.product_id is null


select * from product_sales_test pst where pst.product_id = 99000 
select * from products_test
DECLARE @id INT
select @id = pt.id from products_test pt where pt.id = 33
print @id


select * from products_test
select * from product_sales_test pst order by product_id






-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $12
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT * FROM SYSOBJECTS WHERE xtype = 'u'
SELECT * FROM SYS.tables
select * from INFORMATION_SCHEMA.TABLES

if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'example' and TABLE_SCHEMA = 'dbo')
begin

end
else
begin

end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $13
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- how to group by different criteria in one table 


select t.Name, d.Name, sum(e.Salary) as total_salary 
  from Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  join Addresses a   on a.AddressID = e.AddressID
  join Towns t       on t.TownID = a.TownID
group by grouping sets
(
  (t.Name, d.Name),
  (t.name),
  ()
)
order by grouping(d.Name), GROUPING(t.Name)


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
--                                                                             $14
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
             AVG(e.Salary) over(partition by e.DepartmentId) average,
             min(e.Salary) over(partition by e.DepartmentId) minimum,
             max(e.Salary) over(partition by e.DepartmentId) maximum,
             ROW_NUMBER()  over(partition by e.DepartmentId order by salary) [row_number],
             RANK()        OVER(partition by e.departmentId order by salary) rank_column_with_partition,
             DENSE_RANK()  OVER(partition by e.departmentId order by salary) dense_rank_column_with_partition,
             RANK()        OVER( order by salary) rank_column_without_partition,
             DENSE_RANK()  OVER( order by salary) dense_rank_column_without_partition
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
--                                                                             $15
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- how to get running total value as additional column

select e.FirstName, 
       e.LastName,
       e.Salary
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
declare @temp_salary int SET @temp_salary = 0

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
     set @temp_salary = (select running_total_salary from #tempEmp where row_num = @row_num)
    PRINT @temp_salary
    FETCH NEXT FROM total_result_c INTO  @Salary, @row_num
  END
CLOSE total_result_c
DEALLOCATE total_result_c

select * from #tempEmp




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             001
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO check for dependency in any sp
  sp_depends spe_with_output_param


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             002
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             003
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////