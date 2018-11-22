
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--      																		      																		MIX
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		GROUP BY 
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
				(SELECT avg(e.Salary)
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
--																				      																		OVER 
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
  CREATE OR ALTER VIEW cte__custom_table_rows	
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

	CREATE OR ALTER VIEW cte__table_rows_salary
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
	          FROM cte__table_rows_salary e 
					 WHERE e.row_num = ctr.row_num + 1) AS next_salary
    FROM cte__custom_table_rows AS ctr

-- second option - the difference is only the JOIN
	 SELECT ctr.EmployeeID,
					ctr.row_num,
					ctr.FirstName,
					ctr.LastName,
					ctr.Salary,
					aNextSalary.Salary
					FROM cte__custom_table_rows AS ctr 
LEFT JOIN (SELECT e.Salary, 
									e.row_num
	           FROM cte__table_rows_salary e ) aNextSalary ON aNextSalary.row_num =  ctr.row_num + 1

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
							 e.row_num
	       FROM (SELECT emp.Salary,
										  ROW_NUMBER() OVER (ORDER BY employeeID) row_num
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
					 FROM cte__table_rows_salary e 
					WHERE e.row_num = ctr.row_num + 1) AS next_salary,
				(SELECT (ctr.Salary - (SELECT e.Salary 
																 FROM cte__table_rows_salary e 
																WHERE e.row_num = ctr.row_num + 1 ))) column_difference
   FROM cte__custom_table_rows AS ctr

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
													      FROM cte__table_rows_salary e 
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
			 SUM(Salary)	OVER (ORDER BY EmployeeID) sumsalary,
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
		     COUNT(*)		   OVER (ORDER BY e.Salary) row_num_by_salary,
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
 

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		WITH 
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
INNER JOIN Departments d		 ON D.DepartmentID = e.DepartmentID
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
-- 																				      																		VIEW (virtual table based on a SELECT query)
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	USE SoftUni 
	GO

 -- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie filter employee by department name and in this example this is 'Engineering'
	CREATE OR ALTER VIEW cte_filter_by_department
	AS
	(
		SELECT e.FirstName, 
			     e.LastName 
	    FROM Employees e
INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
		 WHERE d.[Name] = 'Engineering'
	)
	GO
  SELECT * FROM cte_filter_by_department
	GO

-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie returns department with more employee than 20 
	CREATE OR ALTER VIEW cte_another_version
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
    FROM cte_another_version 
   WHERE totalEmployees > 20


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 																				      																		TEMPORARY TABLES(Local and Global Examples)
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1 - Local Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||


-- they are existing only for current window
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
-- second option
  SELECT FirstName
    INTO #PersonDetails
    FROM Employees

	SELECT * FROM #PersonDetails
	DROP TABLE IF EXISTS #PersonDetails


 -- insert in #temp_t table with no need of creating
 
 -- first option
	SELECT firstname
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

-- when temporary table  is inside stored procedure get dropped once this sp complete it's execution 
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
-- in this case the select statement will rturn error  
	SELECT * FROM #person_details

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2 - Global Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||

-- they are existing for all windows 
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
	DECLARE @TableEmployeeCount TABLE(DepartmentName NVARCHAR(50), DepartmentId INT, TotalEmployees INT)

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
--second step is to create a procedure and to put this variable 'table_variable' as parameter and with name '@table_variable'
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

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		SUBSTRING
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	GO
 -- what it does : 
 -- in the following examples extract 4096 characters as starting from 1 
 -- using coalesce it says if the variable inside is null it will return the string inside bettween quotes which is 'NULL',IF NOT  it will return the actuall value
 -- of the variable because that is what COALESCE does  - return the first value different than NULL

 -- ^^^^^^^^ example 1  ^^^^^^^^

	DECLARE @v_log_info				NVARCHAR(2048); SET @v_log_info = '';
	DECLARE @i_location_code	NVARCHAR(10)	  SET @i_location_code = NULL
	DECLARE @i_warehouse_code NVARCHAR(10)	  SET @i_warehouse_code = '34RREWR'

	SELECT @v_log_info = SUBSTRING(
  'Procedure bmever.spe__GetContainerCount <'   
	+ '@i_location_code = '    +  '''' + COALESCE(@i_location_code,'NULL')  + ''''
	+ ', @i_warehouse_code = ' +  '''' + COALESCE(@i_warehouse_code,'NULL') + ''''
  + '>', 1, 4096);
	PRINT @v_log_info

	GO

-- ^^^^^^^^ example 2  ^^^^^^^^

	DECLARE @v_log_info						  NVARCHAR(2048); SET @v_log_info = '';
	DECLARE @i_creation_dt					DATETIME ;			SET @i_creation_dt = '2017-06-14 09:13:02.150';
	DECLARE @i_completion_dt				DATETIME ;			SET @i_completion_dt = '2017-06-14 09:15:56.490'
	DECLARE @i_handling_user_code   NVARCHAR(30)		SET @i_handling_user_code = 'JDO'
	DECLARE @i_task_status					SMALLINT				SET @i_task_status = 80

	SELECT @v_log_info = SUBSTRING(
  'Procedure spr__printing_report_data <'   
	+ '@i_creation_dt = '		              +		COALESCE(CAST(@i_creation_dt   AS NVARCHAR(50)),'NULL')
	+ ', @i_completion_dt = '             +		COALESCE(CAST(@i_completion_dt AS NVARCHAR(50)),'NULL')
  + ', @i_handling_user_code = ' + '''' +   COALESCE(@i_handling_user_code, 'NULL') + ''''
	+ ', @i_task_status = '		            +		COALESCE(CAST(@i_task_status   AS NVARCHAR(20)),'NULL')
	+ '>', 1, 4096);

	PRINT @v_log_info

-- ^^^^^^^^ example 3  ^^^^^^^^

-- this is just to demonstrate how to escape single quotes
	GO

	DECLARE @test_print NVARCHAR(2048);		SET @test_print = '';
	DECLARE @test_var	NVARCHAR(30)		    SET @test_var = 'first_print_message'

	SELECT @test_print = SUBSTRING('this is test print :<' + '@test_var = ' + '   ''   ' + COALESCE(@test_var,'null') + '''',1,300)
	PRINT @test_print

-- ^^^^^^^^ example 4  ^^^^^^^^

	GO
	DECLARE @v_log_info					NVARCHAR(2048);     SET @v_log_info = '';
	DECLARE @i_first_number			INT									SET @i_first_number = 50
	DECLARE @i_second_number		INT									SET @i_second_number = 60
	DECLARE @o_sum_two_numbers	INT									SET @o_sum_two_numbers = @i_first_number +@i_second_number
	DECLARE @i_final_message		NVARCHAR(50)				SET @i_final_message = 'FINAL'

	SELECT @v_log_info = REPLACE(
	'Procedure bmever.cap__get_sum_of_two_numbers' 
	+ ' <@i_first_number = '						+	RTRIM(COALESCE(CAST(@i_first_number	    AS NVARCHAR(20)), '<null>')) 
	+ ', @i_second_number = '						+	RTRIM(COALESCE(CAST(@i_second_number		AS NVARCHAR(20)), '<null>')) 
	+ ', @o_sum_two_numbers = '				  +	RTRIM(COALESCE(CAST(@o_sum_two_numbers  AS NVARCHAR(20)), '<null>')) 
	+ ', @i_final_message = '   + ''''  + RTRIM(COALESCE(@i_final_message, '<null>')) + '''' +
  '>', '''<null>''', 'NULL');
	PRINT @v_log_info

	GO

-- ^^^^^^^^ example 5  ^^^^^^^^

	DECLARE @v_log_info					NVARCHAR(2048);     SET @v_log_info = '';
	DECLARE @i_first_number			INT									SET @i_first_number = 50
	DECLARE @i_second_number		INT									SET @i_second_number = 60
	DECLARE @o_sum_two_numbers	INT									SET @o_sum_two_numbers = @i_first_number +@i_second_number


	SELECT @v_log_info = SUBSTRING(
  'Procedure spe__get_container_count <'   
	+ '@i_first_number = '		  + COALESCE(CAST(@i_first_number    AS NVARCHAR(20)),'NULL')
	+ ', @i_second_number = '	  + COALESCE(CAST(@i_second_number   AS NVARCHAR(20)),'NULL')
  + ', @o_sum_two_numbers = ' + COALESCE(CAST(@o_sum_two_numbers AS NVARCHAR(20)),'NULL')
	+ '>', 1, 4096);
	PRINT @v_log_info
	GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		COALEASCE
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	GO 
-- what it does : 
-- return the first value which is NOT NULL

-- ^^^^^^^^ example 1  ^^^^^^^^

	DECLARE @First		  NVARCHAR(MAX) SET @First = NULL
	DECLARE @InBetween	NVARCHAR(MAX) 
	DECLARE @Second		  NVARCHAR(MAX) SET @Second = 'SECOND'
	DECLARE @Third			NVARCHAR(MAX) SET @Third = 'THIRD' 

	SELECT COALESCE(@First,@InBetween,@Second,@Third)

-- ^^^^^^^^ example 2  ^^^^^^^^

	DECLARE @v_log_info										NVARCHAR(2048);   SET @v_log_info = '';
	DECLARE @i_first_option_null_value		NVARCHAR(50)			SET @i_first_option_null_value = null;
	DECLARE @i_secon_option_empthy_string NVARCHAR(50)			SET @i_secon_option_empthy_string = '';

-- in first option on the table column the result will be "the result is <null>"
	SELECT @v_log_info = (COALESCE(@i_first_option_null_value,'<NULL>'))
	SELECT CONCAT('THE RESULT IS ', @v_log_info)
-- in second option on the table column the result will be "the result is "
	SELECT @v_log_info = (COALESCE(@i_secon_option_empthy_string,'<null>'))
	SELECT CONCAT('the result is ', @v_log_info)
-- that is the difference bettween null and string empthy 


 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				       																		@@ROWCOUNT
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	GO
-- what it does : 
-- it shows the count of the rows 
	SELECT e.* 
		FROM Employees e 
	 WHERE e.FirstName like 'p%'
	SELECT @@ROWCOUNT

	SELECT TOP 2 * 
		FROM Employees e 
	 WHERE e.FirstName like 'p%'
	SELECT @@ROWCOUNT

	SELECT TOP 1 * 
		FROM Employees e 
	 WHERE e.FirstName like 'p%'
	SELECT @@ROWCOUNT

 
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		TRY - CATCH
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
--																				      																		UNION and UNION ALL
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- ^^^^^^^^ example 1  ^^^^^^^^
	
	GO
	WITH cte_first_test(first_name, job_title)
	AS
	(
		SELECT e.FirstName,
					 e.JobTitle 
			FROM Employees e
	), cte_second_test(first_name2,job_title2)
	AS
	(
		SELECT e2.FirstName,
					 e2.JobTitle 
		  FROM Employees e2
	)

-- with UNION ALL we get all the records  and in this case they will be DUPLICATED
	SELECT * FROM cte_first_test
	UNION ALL
	SELECT * FROM cte_second_test

	-- ^^^^^^^^ example 2  ^^^^^^^^

 -- in this case we will get only the UNIQUE records who are not duplicated and perform DISTINCT SORT
	GO
	GO
	WITH cte_first_test(first_name, job_title)
	AS
	(
		SELECT e.FirstName,
					 e.JobTitle 
			FROM Employees e
	), cte_second_test(first_name2,job_title2)
	AS
	(
		SELECT e2.FirstName,
					 e2.JobTitle 
		  FROM Employees e2
	)

	SELECT * FROM cte_first_test 
	UNION 
	SELECT * FROM cte_second_test


 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				      																		CASE 
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
				 WHEN e.Salary  > 400						   THEN 'high'
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
--																																								ISNULL 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	USE SoftUni
	GO

-- ^^^^^^^^ example 1  ^^^^^^^^

-- simple sp  with optional param - if is null or 0 will give all record from the table otherwise it will give record according department id from test parm
	CREATE OR ALTER PROCEDURE sp_test
	(
		@test_param INT = 0
	)
	AS
	BEGIN
				SELECT e.FirstName,
							 e.LastName 
					FROM Employees e
				 WHERE (ISNULL(@test_param , 0) = 0  OR (e.DepartmentID = @test_param))
	END

	EXEC sp_test @test_param = 0

	SELECT e.FirstName,e.LastName 
		FROM Employees e 
	 WHERE e.DepartmentID = '3'

	SELECT e.DepartmentID 
	  FROM Employees e 
	 WHERE e.FirstName = 'guy'

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																																								LEAD 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
USE SoftUni
GO

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie returns empID, row number, firstname, lastname, salary, next row salary, and difference bettween last two column 
	SELECT e.EmployeeID,
			   e.[row_number],
				 e.FirstName, 
				 e.LastName,
				 e.Salary,
				 e.next_row_salary,
				 e.column_difference
	 FROM (SELECT emp.EmployeeID,
								ROW_NUMBER() OVER (ORDER BY emp.EmployeeID) [row_number],
								emp.FirstName,
								emp.LastName,
								emp.Salary,
								LEAD(emp.Salary) OVER (ORDER BY emp.EmployeeID) AS next_row_salary,
								(emp.Salary - LEAD(emp.Salary) OVER (ORDER BY emp.EmployeeID)) column_difference
		FROM Employees emp) e
GO

-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie is simular to the first example BUT it is now quite correct because use employeeID number as reference and if a record it is deleted
-- then the result in next columns will be wrong , and actually it can be seen on the example
SELECT e.EmployeeID,
       e.[row_number],
			 e.FirstName,
	     e.LastName,
	     e.Salary,
	     e.next_salary,
	     e.column_difference	   
 FROM (SELECT emp.EmployeeID,
						  ROW_NUMBER() OVER (ORDER BY EmployeeID) [row_number],
							emp.FirstName,
							emp.LastName,
							emp.Salary,
						 (SELECT ie.Salary 
								FROM Employees ie 
							 WHERE ie.EmployeeID = emp.EmployeeID + 1)			         AS next_salary,
						 (emp.Salary - (SELECT e1.Salary 
															FROM Employees e1 
														 WHERE e1.EmployeeID = emp.EmployeeID + 1)) AS column_difference
				 FROM Employees AS emp ) e	

-- ^^^^^^^^ example 3  ^^^^^^^^

-- this is the right way to be done unlike of example 2 
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
   INNER JOIN (SELECT e.Salary, 
										  e.row_num
								FROM (SELECT emp.Salary,
													   ROW_NUMBER() OVER (ORDER BY employeeID) row_num
											  FROM Employees emp) e ) aNextSalary ON aNextSalary.row_num =  ctr.row_num + 1

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				NTILE() 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie just create temp table with some data inside and split it per 2 groups
	CREATE TABLE  #temp
	(
		StudentID CHAR(2),    
		Marks			INT
	) 
	INSERT #temp  VALUES('S1',75 ) 
	INSERT #temp  VALUES('S2',83)
	INSERT #temp  VALUES('S3',91)
	INSERT #temp  VALUES('S4',83)
	INSERT #temp  VALUES('S5',93 ) 


	SELECT NTILE(2) OVER(ORDER BY Marks),*
	  FROM #temp
ORDER BY Marks

-- ^^^^^^^^ example 2  ^^^^^^^^

 -- split the data into 3 groups  and each group has unique number, and in this example the whole data is grouped or partitioned by salary
 -- it means each salary group is splitted by 3 
	SELECT e.FirstName,
				 e.LastName,
				 e.Salary,
				 NTILE(3) OVER (PARTITION BY e.Salary ORDER BY e.salary) ntile_column			 
				 FROM Employees e

  -- ^^^^^^^^ example 3  ^^^^^^^^

-- this querie split the data into 3 groups and you can use each group as you like :
-- this querie  returns all the people from the first group 
SELECT  groups.* 
FROM (SELECT e.FirstName,
						 e.LastName,
						 e.Salary,
						 NTILE(3) OVER ( ORDER BY e.EmployeeID) ntile_groups			 
				FROM Employees e) groups
			 WHERE groups.ntile_groups = 1


  -- ^^^^^^^^ example 4  ^^^^^^^^

  -- this querie returns all the people from the first group who has salary equal to 10000
  SELECT  groups.* 
	  FROM ( SELECT e.FirstName,
									e.LastName,
									e.Salary,
									NTILE(3) OVER (PARTITION BY e.Salary ORDER BY e.EmployeeID) ntile_groups			 
						 FROM Employees e
					  WHERE e.Salary = 10000) groups
						WHERE groups.ntile_groups = 1






