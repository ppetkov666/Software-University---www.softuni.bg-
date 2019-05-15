



-- 001 - GROUP BY clause
-- 002 - JOINS clause 
-- 003 - OVER clause 
-- 004 - WITH clause
-- 005 - VIEW table
-- 006 - TEMPORARY table 
--       Local
--       Global
--       Table variable
-- 007 - TRY - CATCH block
-- 008 - UNION and UNION ALL clause 
-- 009 - CASE statement
-- 010 - MERGE statement
-- 011 





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                               001  GROUP BY 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
USE SoftUni
 GO

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie returns firstname, lastname, depID, and salary of the people who has salary higher than average for their department

-- first solution - the original one
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID,
         e.Salary
    FROM Employees e
   WHERE Salary > (SELECT AVG(Salary) average_salary_per_department 
                     FROM Employees e1
                    WHERE e.DepartmentID = e1.DepartmentID
                 GROUP BY DepartmentID)

-- second solution - with advanced columns
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID,
         e.Salary AS salary_per_person,
        (SELECT AVG(e.Salary)
           FROM Employees e 
          WHERE e.DepartmentID = d.DepartmentID 
       GROUP BY e.DepartmentID) average_salary_per_department
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
   WHERE e.Salary > (SELECT AVG(salary) average_salary_per_department 
                       FROM Employees e1 
          --WHERE e1.DepartmentID = e.DepartmentID   both options are legit(WHERE and HAVING)
                   GROUP BY DepartmentID
                     HAVING e1.DepartmentID = e.DepartmentID)

-- third solution but with select statement implemented in JOIN 
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID,
         e.Salary AS salary_per_person,
         emp.average_salary_per_dept
    FROM Employees e
    JOIN (SELECT AVG(e.Salary) average_salary_per_dept,DepartmentID 
            FROM Employees e 
        GROUP BY e.DepartmentID) emp ON emp.DepartmentID = e.DepartmentID
           WHERE e.Salary > emp.average_salary_per_dept

-- fourth solution - with additional aggregated functions 
 SELECT e.FirstName,
        e.LastName,
        e.DepartmentID,
        e.Salary AS salary_per_person,
        (SELECT avg(e.Salary)
           FROM Employees e 
          WHERE e.DepartmentID = d.DepartmentID 
       GROUP BY e.DepartmentID) average_salary_per_department,
        (SELECT min(e.Salary)
           FROM Employees e 
          WHERE e.DepartmentID = d.DepartmentID 
       GROUP BY e.DepartmentID) min_salary,
        alias.max_salary
   FROM Employees e
   JOIN Departments d ON d.DepartmentID = e.DepartmentID
   JOIN (SELECT e.DepartmentID deps,
                MAX(e.Salary) max_salary,
                AVG(e.Salary) average 
           FROM Employees e 
       GROUP BY DepartmentID) AS alias ON alias.deps = e.DepartmentID
   WHERE e.Salary > alias.average   

-- fifth solution - all select statements are in the join and is far more 'readable'
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID,
         e.Salary AS salary_per_person,
         alias.average_salary,
         alias.min_salary,
         alias.max_salary
    FROM Employees e
    JOIN (SELECT e.DepartmentID deps,
               MAX(e.Salary) max_salary,
               MIN(e.Salary) min_salary,
               AVG(e.Salary) average_salary
          FROM Employees e 
      GROUP BY DepartmentID) AS alias ON alias.deps = e.DepartmentID --AND e.Salary > alias.average_salary
         WHERE e.Salary > alias.average_salary     

SET STATISTICS TIME OFF

-- six solution with additional over clause and additional columns 
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID, 
         e.Salary,
         alias.average,
         COUNT(*)      OVER (PARTITION BY e.departmentId) total_each_department,
         AVG(e.Salary) OVER (PARTITION BY departmentId) 'AVERAGE FOR PEOPLE WITH HIGHER SALARY THAN AVERAGE SALARY IN DEPARTMENT',
         MIN(e.Salary) OVER (PARTITION BY e.departmentId) MINSALARY, 
         MAX(e.Salary) OVER (PARTITION BY e.departmentId) MAXSALARY
    FROM Employees e
    JOIN (SELECT AVG(d.Salary) average, 
                   d.DepartmentID dept 
              FROM Employees d 
          GROUP BY DepartmentID) alias ON alias.dept = e.DepartmentID
   WHERE e.Salary > alias.average
    

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                      002 - JOINS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
USE Joins_Test_DB


-- ^^^^^^^^ example 1  ^^^^^^^^

-- inner join match only the common rows from both tables
SELECT * FROM Users
SELECT * FROM Department

    SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
INNER JOIN Department d on d.Id = u.DepartmentId

-- ^^^^^^^^ example 2  ^^^^^^^^

-- left join match all records from left table + common record from right table
    SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 LEFT JOIN Department d on d.Id = u.DepartmentId

-- this is opposite 
    SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 LEFT JOIN Department d on d.Id = u.DepartmentId
     WHERE u.DepartmentId is null


-- ^^^^^^^^ example 3  ^^^^^^^^

-- right join match all records from the right + common records from the left
 SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 RIGHT JOIN Department d on d.Id = u.DepartmentId

-- oppsite querie 
    SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 RIGHT JOIN Department d on d.Id = u.DepartmentId
      WHERE u.[Name] is null
      
 -- ^^^^^^^^ example 4  ^^^^^^^^

-- full join - just join the full information from both tables
 SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 FULL JOIN Department d on d.Id = u.DepartmentId

-- oppsite querie
 SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
 FULL JOIN Department d on d.Id = u.DepartmentId
     WHERE d.DepartmentName IS NULL 
        OR u.DepartmentId    IS NULL

-- ^^^^^^^^ example 5  ^^^^^^^^

-- cross join associate each record from first table with each reacord from second table example:
-- first table users has 9 records and every row is assosiated with all 4 rows from the second table Department - total 36 rows in Cross Join statement
 SELECT u.[Name],
           u.Gender,
           u.Salary,
           d.DepartmentName 
      FROM Users u
CROSS JOIN Department d 

-- ^^^^^^^^ example 6  ^^^^^^^^

-- this is great example for self join
-- little explanation.. maya, silvia, ted and mark has manager id 6 which is greta.Greta is theirs manager , and she has manager id 1 , which means her manager is John
-- John has no manager ID so which means he is on top 
-- so basically we join the same table employee ON : we take from the second table Employee as M it's Employee id which is primary key  and has to be equal to 
-- manager id from the first table
USE db_for_test_purposes

-- we will demonstrate couple different approaches how to replace null value if there is no manager accross the certain employee.
SELECT * FROM Employees

    SELECT e.firstname,
              --REPLACE(m.Name,'null','No Manager')            
              --ISNULL(m.Name,'No Manager')
              --COALESCE(m.Name,'No manager')
              CASE 
              WHEN m.Firstname IS NULL THEN 'No manager' 
              ELSE m.Firstname 
              END 
      FROM Employees e
LEFT JOIN Employees m ON m.EmployeeId = e.ManagerId


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                     003 - OVER  
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  USE SoftUni

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie returns firstname, lastname, salary, depID, people_per_department, row_numbers_per_department,
-- and people_per_department_v2 which actually give us the sum of all people department by department  
GO
  SELECT e.FirstName,
          e.LastName,
         e.Salary,
         e.DepartmentID, 
         COUNT(*)     OVER (PARTITION BY departmentID ) people_per_department ,
         ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY departmentID) row_numbers_per_department,
         COUNT(*)     OVER (ORDER BY departmentID ) people_per_department_v2
    FROM Employees e
    
-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie returns firstname, lastname, salary as a group  and count of per this group  
  SELECT e.FirstName,
         e.LastName,
         e.Salary,  
         COUNT(*) count_of_people_per_group__first_name_last_name_salary
    FROM Employees e
GROUP BY e.FirstName,
         e.LastName,
         e.Salary
 
-- ^^^^^^^^ example 3  ^^^^^^^^

-- this querie returns firstname, lastname, salary, depID and every next salary  in column 'next_salary_from_salary'
-- using LEAD function, when there is no record returns '-1', and all this is grouped or partitioned by depID

  SELECT e.FirstName,
         e.LastName,
         e.Salary,
         e.DepartmentID,
         LEAD(e.Salary, 1, -1) OVER (PARTITION BY e.departmentID ORDER BY e.Salary) AS next_salary_from_salary
    FROM Employees e

-- same type of querie but with more simple LEAD and OVER clause
  SELECT e.EmployeeID,
         e.FirstName,
         e.LastName,
         e.Salary,
         LEAD(e.Salary) OVER (order by e.employeeID)  next_salary
    FROM Employees e

-- ^^^^^^^^ example 4  ^^^^^^^^ 
-- this querie returns firstname, lastname, salary, depID and every next salary
-- same type of querie as result set as above but accomplished WITHOUT LEAD clause, with created VIEW 
 GO
  CREATE OR ALTER VIEW v__custom_table_rows  
  AS
  (
   SELECT emp.EmployeeID,
          emp.FirstName,
          emp.LastName,
          emp.Salary,
          ROW_NUMBER() OVER (ORDER BY employeeID) row_num
          FROM Employees emp
  )
GO



  CREATE OR ALTER VIEW v__table_rows_salary
  AS
  (
  SELECT emp.Salary,
         ROW_NUMBER() OVER (ORDER BY employeeID) row_num
    FROM Employees emp
  )
GO

-- first option
  SELECT ctr.EmployeeID,
         ctr.row_num,
         ctr.FirstName,
         ctr.LastName,
         ctr.Salary,
         (SELECT e.Salary 
            FROM v__table_rows_salary e 
           WHERE e.row_num = ctr.row_num + 1) AS next_salary
    FROM v__custom_table_rows AS ctr

-- second option - the difference is only the JOIN
   SELECT ctr.EmployeeID,
          ctr.row_num,
          ctr.FirstName,
          ctr.LastName,
          ctr.Salary,
          aNextSalary.Salary
          FROM v__custom_table_rows AS ctr 
LEFT JOIN (SELECT e.Salary, 
                  e.row_num
             FROM v__table_rows_salary e ) aNextSalary ON aNextSalary.row_num =  ctr.row_num + 1

-- third option - the only difference here is : the result is accomplished WITHOUT using VIEW, just with DERIVED tables and INNER JOIN

 SELECT ctr.EmployeeID,
        ctr.row_num,
        ctr.FirstName,
        ctr.LastName,
        ctr.Salary,
        aNextSalary.Salary
  FROM (SELECT emp.EmployeeID,
               emp.FirstName,
               emp.LastName,
               emp.Salary,
               ROW_NUMBER() OVER (ORDER BY employeeID) row_num
          FROM Employees emp) AS ctr 
  JOIN (SELECT e.Salary, 
               e.row_number_in as row_num
         FROM (SELECT emp.Salary,
                      ROW_NUMBER() OVER (ORDER BY employeeID) row_number_in
                 FROM Employees emp) e ) aNextSalary ON aNextSalary.row_num =  ctr.row_num + 1
 GO

-- ^^^^^^^^ example 5  ^^^^^^^^ 

-- this querie is similuar to previous but also calculate column differences again using VIEW

-- first option
  SELECT ctr.EmployeeID,
         ctr.row_num,
         ctr.FirstName,
         ctr.LastName,
         ctr.Salary,
        (SELECT e.Salary 
           FROM v__table_rows_salary e 
          WHERE e.row_num = ctr.row_num + 1) AS next_salary,
        (SELECT (ctr.Salary - (SELECT e.Salary 
                                 FROM v__table_rows_salary e 
                                WHERE e.row_num = ctr.row_num + 1 ))) column_difference
   FROM v__custom_table_rows AS ctr

-- second option
-- calculate column differences WITHOUT using any VIEW, just with derived tables
  SELECT ctr.EmployeeID,
         ctr.row_num,
         ctr.FirstName,
         ctr.LastName,
         ctr.Salary,
       (SELECT e.Salary 
          FROM (SELECT emp.Salary,
                       ROW_NUMBER() OVER (ORDER BY employeeID) row_num
                  FROM Employees emp) e 
                 WHERE e.row_num = ctr.row_num + 1) AS next_salary,
       (SELECT (ctr.Salary - (SELECT e.Salary 
                                FROM v__table_rows_salary e 
                               WHERE e.row_num = ctr.row_num + 1 ))) column_difference
  FROM (SELECT emp.EmployeeID,
               emp.FirstName,
               emp.LastName,
               emp.Salary,
               ROW_NUMBER() OVER (ORDER BY employeeID) row_num
          FROM Employees emp) AS ctr
   

 -- ^^^^^^^^ example 6  ^^^^^^^^

 -- this querie just demonstrate how  RANK and DENSE_RANK works
 -- RANK and DENSE_RANK example: 
 -- RANK: 1,1,1,1,5,5,5,5,5,10,10.....; DENSE_RANK: 1,1,1,1,2,2,2,2,2,3,3.....


  SELECT e.FirstName,
         e.LastName,
         e.Salary, 
         RANK()        OVER (ORDER BY e.salary) [rank], 
         DENSE_RANK () OVER (ORDER BY e.salary) denseRank,
         ROW_NUMBER () OVER (ORDER BY e.salary) rowNumber
    FROM Employees e  

-- ^^^^^^^^ example 7  ^^^^^^^^

-- this querie order all salaries by their rank from the botton to the top and take the employee with the third salary from the bottom, ordered by firstname
  SELECT TOP(1) 
         emp.FirstName,
         emp.LastName,
         emp.salary
    FROM (SELECT e.FirstName,
                 e.LastName,
                 e.Salary,
                 DENSE_RANK () OVER (ORDER BY e.salary) salary_rank 
            FROM Employees e) emp
   WHERE emp.salary_rank = 3
ORDER BY FirstName


-- ^^^^^^^^ example 8  ^^^^^^^^

-- this querie returns firstname, lastname, salary, deptID, count of people per dept, avg salary, min salary, max salary, sum of the salary till each row, and row number 
SELECT e.FirstName,
       e.LastName,
       e.Salary,
       e.DepartmentID, 
       COUNT(*)     OVER (PARTITION BY DepartmentID) totalCountOfPeoplePerDepartment,
       AVG(Salary)  OVER (PARTITION BY DepartmentID) averageSalary,
       MIN(Salary)  OVER (PARTITION BY DepartmentID) minimumSalary,
       MAX(Salary)  OVER (PARTITION BY DepartmentID) maximumSalary,
       SUM(Salary)  OVER (ORDER BY EmployeeID) sumsalary,
       ROW_NUMBER() OVER (ORDER BY EmployeeID) rowNumber 
 FROM Employees e

 -- ^^^^^^^^ example 9  ^^^^^^^^
 
-- this querie returns empID, firstname, lastname, salary, and sum of the salary till each row
-- what this SUM OVER does is take first salary , sum with next salary and with next salary and present it on each row 
  SELECT e.EmployeeID,
         e.FirstName,
         e.LastName,
         e.Salary, 
         SUM(e.Salary) OVER (ORDER BY e.employeeID) sum_salary 
    FROM Employees e 
ORDER BY e.EmployeeID


-- ^^^^^^^^ example 10  ^^^^^^^^

-- this example shows what is happening when we join with the same table  and why the table rows are so much replicated 
SELECT  e.EmployeeID,
        e.DepartmentID,
        e.FirstName,
        e.LastName,
        e.Salary,
        e.row_num,

        e1.EmployeeID,
        e1.DepartmentID,
        e1.FirstName,
        e1.LastName,
        e1.Salary,
        e1.row_num
FROM (SELECT emp.EmployeeID,
             emp.DepartmentID,
             emp.FirstName,
             emp.LastName,
             emp.Salary,
             ROW_NUMBER() OVER (ORDER BY employeeID) row_num
        FROM Employees emp) e
JOIN (SELECT emp1.EmployeeID,
             emp1.DepartmentID,
             emp1.FirstName,
             emp1.LastName,
             emp1.Salary,
             ROW_NUMBER() OVER (ORDER BY employeeID) row_num 
        FROM Employees emp1)e1 ON e1.DepartmentID = e.DepartmentID


-- ^^^^^^^^ example 11  ^^^^^^^^

-- this querie calculates the average salary for each row till the last one 
  SELECT e.FirstName,
         e.LastName,
         e.Salary,
         e.DepartmentID,
         AVG(e.Salary) OVER (ORDER BY  e.Salary) average
    FROM Employees e

-- ^^^^^^^^ example 12  ^^^^^^^^

-- this querie returns empID, firstname, lastname, salary, row num, row num ordered by salary, avg salary one before and after actual row, and total row numbers
  SELECT e.EmployeeID,
         e.FirstName,
         e.LastName,
         e.Salary,
         ROW_NUMBER()  OVER (ORDER BY e.Salary) row_num,
         COUNT(*)       OVER (ORDER BY e.Salary) row_num_by_salary,
         AVG(e.Salary) OVER (ORDER BY e.Salary ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) avg_salary_one_row_before_and_after,
         COUNT(*)      OVER (ORDER BY e.Salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) total_row_nums
    FROM Employees e
  
-- ^^^^^^^^ example 13  ^^^^^^^^

-- this querie returns firstname, lastname, depID, salary, row number of each employee and rank by deptID
  SELECT e.FirstName,
         e.LastName,
         e.DepartmentID,
         e.Salary,
         ROW_NUMBER() OVER ( ORDER BY e.FirstName ) row_num,
         RANK()       OVER (PARTITION BY e.DepartmentID ORDER BY e.FirstName ) rank_column
    FROM Employees e
ORDER BY e.DepartmentID
  
-- ^^^^^^^^ example 14  ^^^^^^^^

-- this querie return all people who have third highest salary from the bottom to the top  partitioned by departments 
  SELECT oe.FirstName,
         oe.LastName,
          oe.DepartmentID,
         oe.Salary,
         oe.rank_column FROM 
        (SELECT e.FirstName,
                e.LastName,
                e.DepartmentID,
                e.Salary,
                DENSE_RANK() OVER (PARTITION BY e.DepartmentID ORDER BY e.Salary ) rank_column
    FROM Employees e) oe
   WHERE oe.rank_column = 3

 -- ^^^^^^^^ example 15  ^^^^^^^^
 
 
with cte_temp
as
(
SELECT e.FirstName,
       e.JobTitle,
       dense_RANK() over( order by e.firstname, e.jobtitle) as Ranked_people_by_equal_criteria
      FROM Employees e
 )     

   select FirstName, JobTitle
     from cte_temp 
 group by FirstName,JobTitle
   having COUNT(Ranked_people_by_equal_criteria) > 1


    

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                       004 - WITH 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use SoftUni
GO

-- ^^^^^^^^ example 1  ^^^^^^^^

-- the querie returns all departments who has more than 10 people into it
  WITH cte_filter_by_count 
  AS 
  (
     SELECT DepartmentID, 
        COUNT(*) people_per_group
       FROM Employees e
   GROUP BY DepartmentID
     HAVING COUNT(*) > 10
  )
  SELECT * 
    FROM cte_filter_by_count

GO

-- ^^^^^^^^ example 2  ^^^^^^^^

-- the querie returns only the firstnames of people who are from 'Engineering department'
  WITH cte_filter_first_names 
  AS
  (
        SELECT e.FirstName, 
               e.LastName,
               e.DepartmentID,
               d.[Name] 
          FROM Employees e
    INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
         WHERE d.Name = 'Engineering'
  )
  SELECT f.FirstName 
    FROM CTE_filter_first_names f 
 GO

 -- ^^^^^^^^ example 3  ^^^^^^^^

-- WITH example with PARAMS
-- in this case the name of params does not have to be the same as the names of the colums , just the count must be the same
  WITH cte_filter_by_name(firstname, lastname)
  AS
  (
    SELECT e.FirstName,
           e.LastName 
      FROM Employees e
  )
  SELECT c.firstname 
    FROM cte_filter_by_name c 
GO  


-- ^^^^^^^^ example 4  ^^^^^^^^

-- the querie returns firstname, lastname, department name and count of people per department
  WITH CTE_Employee_Count(departmentID,employee_count_per_department)
  AS
  (
    SELECT e.DepartmentID, 
           COUNT(*) total_count_per_department 
      FROM Employees e
  GROUP BY DepartmentID
  )
  
    SELECT e.FirstName,
           e.LastName,
           d.[Name],
           ec.employee_count_per_department 
      FROM Employees e
INNER JOIN CTE_Employee_Count ec ON EC.departmentID = e.DepartmentID
INNER JOIN Departments d     ON D.DepartmentID = e.DepartmentID
  ORDER BY employee_count_per_department


-- ^^^^^^^^ example 5  ^^^^^^^^

-- the querie returns just update of lastname who follow the condition of the salary.
-- this example shows one other important point that if we want to use WITH in transaction we should use ';'

  USE UserInfo

  BEGIN TRANSACTION;

  WITH cte_simple_querie_test
  AS
  (
    SELECT uit.FirstName,
           uit.LastName,
           uit.Salary 
      FROM UserInfoTable uit
     WHERE uit.Salary > 200
  )
  
  UPDATE cte_simple_querie_test 
     SET LastName = 'test_family'
   WHERE Salary = 500

  COMMIT TRANSACTION

 -- ^^^^^^^^ example 6  ^^^^^^^^
  USE SoftUni
-- the querie returns the third department with most people 
  GO
  WITH cte_get_count_of_people_per_dep
  AS
  (
    SELECT e.DepartmentID, 
           COUNT(*) total_count_per_department,
           DENSE_RANK() OVER (ORDER BY count(*) desc) department_rank
      FROM Employees e
  GROUP BY e.departmentID
  )
  SELECT cte.* 
    FROM cte_get_count_of_people_per_dep cte
   WHERE cte.department_rank = 3

-- this is same querie but without dense_rank and with, just simple derived table
  SELECT TOP (1) x.*
    FROM ( SELECT TOP (3) e.DepartmentID, 
              COUNT(*) total_count_per_department
           FROM Employees e
GROUP BY e.departmentID
ORDER BY total_count_per_department DESC) x
ORDER BY total_count_per_department ASC

-- ^^^^^^^^ example 7  ^^^^^^^^

-- the querie returns the department with more people than 20 
  WITH cte_count_per_dept([name] ,dept,total)
  AS
  (
    SELECT d.[Name],
           d.DepartmentID, 
           COUNT(*) totalEmployees 
      FROM Employees e
      JOIN Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],
           d.DepartmentID
  )
  SELECT [name],
         total 
    FROM cte_count_per_dept 
   WHERE total > 20

GO

-- ^^^^^^^^ example 9  ^^^^^^^^

-- the querie returns just added column for row numbers but partitioned by each department
  USE SoftUni   
  WITH cte_custom_view AS
 (
    SELECT e.* , 
           ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY e.employeeID ) AS rownumber 
      FROM Employees e
 )

 SELECT * FROM cte_custom_view
 


 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                            005 - VIEW (virtual table based on a SELECT query)
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  USE SoftUni 
  GO
 -- view cannot be created from temporary tables
 -- view cannot have parameters

 -- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie filter employee by department name and in this example this is 'Engineering'
  CREATE OR ALTER VIEW v_filter_by_department
  AS
  (
    SELECT e.FirstName, 
           e.LastName 
      FROM Employees e
INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
     WHERE d.[Name] = 'Engineering'
  )
  GO
  SELECT * FROM v_filter_by_department
  GO

-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie returns department with more employee than 20 
  CREATE OR ALTER VIEW v_another_version
  AS
  (
    SELECT d.[Name],
           d.DepartmentID, 
           COUNT(*) totalEmployees 
      FROM Employees e
      JOIN Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID
  )
GO
  SELECT * 
    FROM v_another_version
   WHERE totalEmployees > 20

-- option 2
go
CREATE OR ALTER VIEW v_another_versionV2(name_column, department_id, total)
  AS
  (
    SELECT d.[Name],
           d.DepartmentID, 
           COUNT(*) totalEmployees 
      FROM Employees e
      JOIN Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID
  )
go
  SELECT name_column, department_id, total
    FROM v_another_versionV2
   WHERE total > 20



-- indexed view -------------------------------

create table Product
(
id int primary key identity,
[name] varchar(50) ,
price decimal(16,2),
)
insert into Product
values
('product_1',50),
('product_2',100),
('product_3',150),
('product_4',200),
('product_5',250),
('product_6',300),
('product_7',350)

create table orders
(
product_id int FOREIGN KEY (product_id) REFERENCES Product(id),
quantity int
)
insert into orders
values
(7,100),
(2,20),
(3,30),
(4,40),
(5,50),
(6,60),
(7,70),
(1,10),
(1,20),
(2,30),
(6,40),
(4,50),
(4,60),
(7,70)


select * 
  from orders o
  join Product p on p.id = o.product_id 
go
-- the things which are nessesary for indexed view are:
-- count_big, with schemabinding, isnull(if there is possibility for null), and we must use schema_name.table_name
-- they are suitable for data warehouse where the data is not frequiently changed
create or alter view v_totalorders
with schemabinding
as
select p.name, sum(isnull((p.price * o.quantity), 0)) as total, count_big(*) as total_as_sum
  from dbo.orders o
  join dbo.Product p on p.id = o.product_id 
  group by p.name
go
create unique clustered index uix_total_orders on v_totalorders(name)

select * from v_totalorders


-- ----------------------------------------------------------------------------------------------------------------

-- view example : it shows how after update one field from the table is changed on both tables - this is because view is just virtual table
-- updating views has limitations - in this example i have pointed particular case where i can update it

GO
CREATE OR ALTER VIEW v__temp_result  
  AS
  (
   SELECT EmployeeID,
      FirstName,
      LastName,
      Salary,
      NULL AS NextSalary,
      ROW_NUMBER() OVER (ORDER BY employeeID) row_num
   FROM Employees 
  )
 GO
  UPDATE v__temp_result
     SET Salary = 13000
   WHERE FirstName = 'Guy' and LastName = 'Gilbert'


-- ---------------------------------------------
 go
 create or alter view v__temp_result_indexed
with schemabinding
as
(
  select e.employeeid, 
         e.FirstName,
         e.Salary 
    from dbo.Employees e
)
go
create unique clustered index idx_test on v__temp_result_indexed(employeeid)

select * from v__temp_result_indexed

update v__temp_result_indexed
set salary = 13000
WHERE FirstName = 'Guy'



 SELECT * FROM employees
 SELECT * FROM v__temp_result
 SELECT * FROM v__temp_result_indexed

 -- next 2 examples show limitations of updating view
 go
 create or alter view v_test
 as
 (
  select e.DepartmentID,
         sum(e.Salary ) sum_salary
    from dbo.Employees e 
    group by e.DepartmentID
 )
go
 select * from v_test
 update v_test
 set sum_salary += 999999 
 where DepartmentID = 1 



 -- -----------------------------------------------
 go
 create or alter view v_test_v2
 as
 (
  select e.FirstName,
         e.LastName, 
         e.Salary, 
         d.[Name]
    from dbo.Employees e 
    join Departments d on d.DepartmentID = e.DepartmentID
 )
go
select * from Employees
 select * from v_test_v2
 update v_test_v2
 set  Salary = 12500, Name = 'prod techn'
 where FirstName = 'guy' and LastName = 'gilbert'











-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                             006 - TEMPORARY TABLES(Local and Global Examples)
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1 - Local Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||
-- temp tables and table variables are created in tempDb

-- they are existing only for current querie window
  GO
  CREATE TABLE #PersonDetails
  ( 
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50)
  )
  INSERT INTO #PersonDetails
  VALUES
  ('Petko'),
  ('Ivan'),
  ('Georgi')

-- with this querie we can check all tables in tempdb and particulary #PersonDetails 
  SELECT * FROM tempdb..sysobjects
  SELECT [NAME] FROM tempdb..sysobjects
  WHERE NAME LIKE '%#PersonDetails%'

-- insert in already created temp table
  USE SoftUni
-- first option
  INSERT 
    INTO #PersonDetails
  SELECT e.FirstName 
    FROM Employees e
-- second option - with this approach the tempt table is created on the fly
  SELECT FirstName
    INTO #PersonDetails
    FROM Employees

  SELECT * FROM #PersonDetails
  DROP TABLE IF EXISTS #PersonDetails

  -- it is easy way for backup table into another DB
  SELECT *
    INTO userinfo.dbo.backup_table_v_3
    FROM Employees e
   where e.EmployeeID > 33
    select * from dbo.backup_table_v_3

   
    select e.*,d.Name  into userinfo.dbo.backup_table_v_4
    from Employees e
    inner join Departments d on d.DepartmentID = e.AddressID
    WHERE E.EmployeeID > 33

    select * from dbo.backup_table_v_4


    -- this is interesting approach !!!! :
    select * into userinfo.dbo.empthy_table from Employees where 1<>1
    select * from empthy_table
     
 -- insert in #temp_t table with no need of creating
 
 -- first option
  SELECT EmployeeID,firstname
    INTO #temp_t
    FROM Employees

  GO
-- second option
  INSERT 
    INTO #temp_t
  SELECT FirstName 
    FROM Employees

  SELECT * FROM #temp_t
  DROP TABLE IF EXISTS #temp_t

-- when local temporary table  is inside stored procedure get dropped once this sp complete it's execution
  GO
  CREATE OR ALTER PROCEDURE sp_local_temporary_table
  AS
  BEGIN
  CREATE TABLE #person_details
  ( 
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50)
  )
  INSERT INTO #person_details
  VALUES
  ('Petko'),
  ('Ivan'),
  ('Georgi')

  SELECT * FROM #person_details
  END

  EXECUTE sp_local_temporary_table
-- in this case the select statement will return error  
  SELECT * FROM #person_details

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2 - Global Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||

-- they are existing till the last connection is closed
  CREATE TABLE ##employee_details
  ( 
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50)
  )
  INSERT INTO ##employee_details
  VALUES
  ('employee First'),
  ('employee Second'),
  ('employee Third')

SELECT * FROM ##employee_details

  GO
  CREATE OR ALTER PROCEDURE sp__global_temporary_table
  AS
  BEGIN
  CREATE TABLE ##employee_det
  ( 
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50)
  )
  INSERT INTO ##employee_det
  VALUES
  ('Petko'),
  ('Ivan'),
  ('Georgi'),
  ('employee First'),
  ('employee Second'),
  ('employee Third')

  SELECT * FROM ##employee_det
END

EXECUTE sp__global_temporary_table
-- in this case the table will be still existing
  SELECT * FROM ##employee_det

-- |||||||||||||||||||||||||||||||||||||||||||||||||        3 - -- Table variable       |||||||||||||||||||||||||||||||||||||||||||||||||

-- can be passed as param between stored procedures      

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie returns department name and count of employees more than 20 for this particular department
  DECLARE @TableEmployeeCount TABLE(DepartmentName   NVARCHAR(50),
                                    DepartmentId     INT, 
                                    TotalEmployees   INT)

  INSERT 
    INTO @TableEmployeeCount
  SELECT d.[Name],
         d.DepartmentID, 
         COUNT(*) totalEmployees 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
GROUP BY d.[Name],
         d.DepartmentID  

  SELECT DepartmentName,
         TotalEmployees    
    FROM @TableEmployeeCount 
   WHERE TotalEmployees > 20   

  
-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie returns store procedure which use table variable as param and insert records into another table

--first step we create variable of type 'table_variable' which is nothing diffent than other variables as INT NVARCHAR and so on , just
-- this one takes table which we want with the exact columns we want
  CREATE TYPE table_variable AS TABLE
  (
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Salary INT
  )
  GO
  -- or  we can just declare it like :
  DECLARE @table_variable  TABLE (FirstName NVARCHAR(50), 
                                  LastName  NVARCHAR(50), 
                                  Salary    INT)


--second step is to create a procedure and to put this variable  from type 'table_variable' as parameter and with name '@table_variable'
-- it MUST be READONLY 
  USE UserInfo
  GO 
  CREATE or ALTER PROCEDURE sp__insert_employee
  (
    @table_variable  table_variable READONLY
  )
  AS
  BEGIN
  INSERT 
    INTO UserInfoTable
  SELECT * 
    FROM @table_variable
  END
GO
-- third step we declare our variable from type 'table_variable' and we give her name '@table_variable_to_be_passed_to_sp'
-- and we insert records into it
  DECLARE @table_variable_to_be_passed_to_sp table_variable 

  INSERT 
    INTO @table_variable_to_be_passed_to_sp
  SELECT e.FirstName,
         e.LastName, 
         e.Salary 
    FROM UserInfoTable e
      
-- the final part of this is to execute our SP with the parameter this SP takes : is it from type 'table_variable' and the name is @table_variable_to_be_passed_to_sp 
  EXECUTE sp__insert_employee @table_variable_to_be_passed_to_sp

  select * from UserInfoTable


-- |||||||||||||||||||||||||||||||||||||||||||||||||        4 - ExampleS  |||||||||||||||||||||||||||||||||||||||||||||||||
  USE SoftUni
-- ^^^^^^^^ example 1  ^^^^^^^^

-- simple querie example which return the department with more than 20 people inside
-- without temp table - first approach
  SELECT d.[Name],
         d.DepartmentID, 
         COUNT(*) totalEmployees 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
GROUP BY d.[Name],d.DepartmentID
  HAVING COUNT(*) > 20

-- without temp table - second approach with derived table
  SELECT emp.[Name],
         emp.DepartmentID,
         emp.total_employees 
    FROM (SELECT d.[Name],
                 d.DepartmentID, 
                 COUNT(*) total_employees 
            FROM Employees e
            JOIN Departments d ON d.DepartmentID = e.DepartmentID
        GROUP BY d.[Name],d.DepartmentID) AS emp
           WHERE emp.total_employees > 20

-- instead of having query like this with HAVING clause or DERIVED table we can create temp table
-- done with #temp_table
  SELECT d.[Name], 
         e.DepartmentID, 
         count(*) sum_people_per_department 
    INTO  #temp_petko_test
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
GROUP BY d.[Name], e.DepartmentID

  SELECT * FROM #temp_petko_test

  SELECT temp.* 
    FROM #temp_petko_test temp
   WHERE sum_people_per_department > 20
  
  DROP TABLE #temp_petko_test

  GO

 
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                   007 - TRY - CATCH
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  GO  
--  in this particullar case will go exactly in catch because i try to declare variable of type int  with string input  
  BEGIN TRY 
  DECLARE @TEST INT SET @TEST = 'PETKO'
  PRINT 'TRY '  
  END TRY
  BEGIN CATCH    
  PRINT 'CATCH '
  END CATCH

 -- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    008 - UNION and UNION ALL
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



-- ^^^^^^^^ example 1  ^^^^^^^^
  
  GO
  WITH cte_first_test(first_name, job_title)
  AS
  (
    SELECT e.FirstName,
           e.JobTitle 
      FROM Employees e
  ), 
  cte_second_test(first_name2,job_title2)
  AS
  (
    SELECT e2.FirstName,
           e2.JobTitle 
      FROM Employees e2
  )

-- with UNION ALL we get all the records  and in this case they will be DUPLICATED
  SELECT * FROM cte_first_test
  UNION --ALL
  SELECT * FROM cte_second_test

  -- ^^^^^^^^ example 2  ^^^^^^^^

 -- in this case we will get only the UNIQUE records who are not duplicated and perform DISTINCT SORT
  GO
  GO
   

 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    009 - CASE 
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  USE UserInfo
  GO
-- ^^^^^^^^ example 1  ^^^^^^^^

-- add a column with string description for a salary if it's between certain values or type 'error'
  SELECT e.FirstName,
         e.LastName,
         e.Salary,
    CASE  
         WHEN e.salary BETWEEN 100 AND 200 THEN 'low'
         WHEN e.Salary BETWEEN 200 AND 400 THEN 'medium'
         WHEN e.Salary  > 400               THEN 'high'
         ELSE 'ERROR'
     END AS [SALARY DESCRIPTION]
    FROM UserInfoTable e
ORDER BY FirstName

-- ^^^^^^^^ example 2  ^^^^^^^^

-- add a column with string description for a salary if has certain values or if not just type 'default'
     SELECT e.FirstName,
      e.LastName,
      e.Salary,
       CASE e.Salary
            WHEN 100 THEN 'HUNDRED'
            WHEN 400 THEN 'FOUR_HUNDRED'
            WHEN 500 THEN 'FIVE_HUNDRED'
            ELSE 'DEFAULT'
            END AS [SALARY DESCRIPTION]
       FROM UserInfoTable e
   ORDER BY FirstName

   SELECT * FROM UserInfoTable





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                            010 - MERGE
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




   Create table student_source
(
     ID int primary key,
     Name nvarchar(20)
)
GO

Insert into student_source values (1, 'Mike')
Insert into student_source values (2, 'Sara')
GO

Create table student_target
(
     ID int primary key,
     Name nvarchar(20)
)
GO

Insert into student_target values (1, 'Mike M')
Insert into student_target values (3, 'John')
GO

MERGE student_target AS T
USING student_source AS S
ON T.ID = S.ID
WHEN MATCHED THEN
     UPDATE SET T.NAME = S.NAME
WHEN NOT MATCHED BY TARGET THEN
     INSERT (ID, NAME) VALUES(S.ID, S.NAME)
WHEN NOT MATCHED BY SOURCE THEN
     DELETE;
