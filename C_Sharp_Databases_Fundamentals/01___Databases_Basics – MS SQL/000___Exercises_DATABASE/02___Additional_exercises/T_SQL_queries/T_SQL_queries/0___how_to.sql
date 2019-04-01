

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

select * from                                                 
(select e.FirstName,e.LastName,DATEDIFF(YEAR,HireDate,GETDATE()) as 'date diffrence in months' 
  from Employees e) emp
  where [date diffrence in months] < 15


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
                                                            -- HOW TO explain diffference between blocking and deadlocking

--  BLOCKING 
use UserInfo
select * from UserInfoTable
select * from People

begin transaction

update UserInfoTable 
SET FirstName = 'testname' 
where id = 27 

commit transaction

-- if i execute the same transaction from new querie  it will wait until this transaction is committed and then the second transaction will be executed

-- DEADLOCKING
-- in the following example if i execute from this session the UserInfoTable table and from another session the People table , these 2 tables will be locked, 
-- then when i try to execute table people from this session and accordingly UserInfoTable from the other session the deadlock will occur and sql server will 
-- choose one of both transactions as deadlock victim and it will be rollbacked and the other will be completed 
begin transaction

update UserInfoTable 
SET FirstName = 'testname' 
where id = 27 

update People
set Firstname = 'testname'
where id = 2
rollback
commit transaction

select @@trancount  -- check the number of active transactions


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $8
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            -- HOW TO find all names that start with certain letter without like operator

USE SoftUni
-- this is the first option but because of the point of this task i will show other 2 different ways how to be done
SELECT * FROM Employees WHERE FirstName like 'm%'

SELECT * FROM Employees WHERE CHARINDEX('m',FirstName) = 1;
SELECT * FROM Employees WHERE left(FirstName,1) = 'm';
SELECT * FROM Employees WHERE SUBSTRING(FirstName,1,1) = 'm'


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $9
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

DECLARE @student_name NVARCHAR(50) SET @student_name = 'PETKO'
DECLARE @course_name NVARCHAR(50)  SET @course_name = 'c#'

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
END

IF(@course_id is null)
BEGIN
  INSERT INTO Courses VALUES(@course_name)
  SELECT @course_id = SCOPE_IDENTITY()
END

insert into StudentCourses values (@student_id,@course_id)

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
--                                                                             $10
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
--                                                                             $12
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
--                                                                             $13
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $14
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $15
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             $16
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






















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