USE SoftUni
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				GROUP BY 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 GO
                                              
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

	-- this is the same querie as above but with select statement implemented in JOIN 
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
-- simular as the second solution but with additional aggregated functions and select statements on 2 diffferent positions - 
-- 
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
	JOIN(SELECT e.DepartmentID deps,
				max(e.Salary) max_salary,
				AVG(e.Salary) average 
		   FROM Employees e 
	   GROUP BY DepartmentID) AS alias ON alias.deps = e.DepartmentID
   WHERE e.Salary > alias.average   -- (SELECT AVG(salary) averageSalaryPerDepartment 
				                    --   FROM Employees e1 
					                --   WHERE e1.DepartmentID = e.DepartmentID   
				                    --GROUP BY DepartmentID)

-- third and the best solution - all select statements are in the join and there isn't such a complicated WHERE clause as in the first one
SELECT e.FirstName,
	     e.LastName,
	     e.DepartmentID,
	     e.Salary AS salary_per_person,
		 alias.average_salary,
		 alias.min_salary,
		 alias.max_salary
    FROM Employees e
		 JOIN(SELECT e.DepartmentID deps,
					 max(e.Salary) max_salary,
					 min(e.Salary) min_salary,
					 avg(e.Salary) average_salary
			    FROM Employees e 
		    GROUP BY DepartmentID) AS alias ON alias.deps = e.DepartmentID --AND e.Salary > alias.average_salary
			   WHERE e.Salary > alias.average_salary		 


GO
SET STATISTICS TIME OFF
-- this is simular to the previous ones but there isn't any additional where clause for the salary
    SELECT e.FirstName,
	       e.LastName, 
		   e.Salary,
		   e.DepartmentID,
		   Departments.total_in_each_department,
		   Departments.AVERAGE,
		   Departments.MINSALARY,
		   Departments.MAXSALARY 
	  FROM Employees e 
INNER JOIN
   (SELECT DepartmentID,
	       COUNT(*) total_in_each_department, 
		   AVG(Salary) AVERAGE, 
	       MIN(Salary) MINSALARY, 
	       MAX(Salary) MAXSALARY
      FROM Employees
  GROUP BY DepartmentID) AS Departments
        ON  Departments.DepartmentID = e.DepartmentID
   --WHERE e.Salary > Departments.AVERAGE  

-- THIS IS SAME query but with over clause 
    SELECT e.FirstName,
	       e.LastName,
		   e.DepartmentID, 
		   e.Salary,
		   alias.average,
		   COUNT(*)    OVER (PARTITION BY e.departmentId) total_each_department,
		   AVG(e.Salary) OVER (PARTITION BY departmentId) 'AVERAGE FOR PEOPLE WITH HIGHER SALARY THAN AVERAGE SALARY IN DEPARTMENT',
		   MIN(e.Salary) OVER (PARTITION BY e.departmentId) MINSALARY, 
		   MAX(e.Salary) OVER (PARTITION BY e.departmentId) MAXSALARY
	  FROM Employees e
	  JOIN (SELECT AVG(d.Salary) average, 
				   d.DepartmentID dept 
		      FROM Employees d 
		  GROUP BY DepartmentID) alias ON alias.dept = e.DepartmentID
	 WHERE e.Salary > alias.average 
	  

  SELECT e.DepartmentID, COUNT(*) 
    FROM Employees e
GROUP BY e.DepartmentID
  HAVING count(*) > 10 

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				OVER 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- example 1
GO
 SELECT e.FirstName,
		e.LastName,
		e.Salary,
		e.DepartmentID, 
		COUNT(*) OVER (PARTITION BY departmentID ) people_per_department ,
		ROW_NUMBER() over (PARTITION BY departmentID order by departmentID) row_numbers_per_department,
		COUNT(*) OVER (ORDER BY departmentID ) people_per_department_v2
   FROM Employees e
   -- same result but done with GROUP BY clause 
    SELECT e.FirstName,
	 	   e.LastName,
		   e.Salary,  
		   COUNT(*) count_of_people_per_group__first_name_last_name_salary
     FROM Employees e
 GROUP BY e.FirstName,
		  e.LastName,
		  e.Salary
 
-- example 2 
-- LEAD clause with OVER example 

 SELECT e.FirstName,
		e.LastName,
		e.Salary,
		e.DepartmentID,
		LEAD(e.Salary, 2, -1) OVER (PARTITION BY e.departmentID order by e.Salary) as next_salary_from_salary
   FROM Employees e

select e.EmployeeID,
	   e.FirstName,
	   e.LastName,
	   e.Salary,
	   LEAD(e.Salary) OVER (order by e.employeeID)  next_salary
  from Employees e

-- -- example 3 - same thing as above but without LEAD clause !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
  FROM cte__custom_table_rows as ctr


 -- calculate column differences using VIEW
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
  FROM cte__custom_table_rows as ctr


  -- calculate column differences without using any VIEW
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
			  FROM Employees emp) as ctr




-- -- second option
	 SELECT ctr.EmployeeID,
			ctr.row_num,
			ctr.FirstName,
			ctr.LastName,
			ctr.Salary,
	        aNextSalary.Salary
       FROM cte__custom_table_rows as ctr 
  LEFT JOIN (SELECT e.Salary, 
					e.row_num
	           FROM cte__table_rows_salary e ) aNextSalary on aNextSalary.row_num =  ctr.row_num + 1

-- third option is without creating  VIEW  ---------------------------------------

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
			  FROM Employees emp) as ctr 
 INNER JOIN (SELECT e.Salary, 
					e.row_num
	           FROM (SELECT emp.Salary,
							ROW_NUMBER() OVER (ORDER BY employeeID) row_num
					   FROM Employees emp) e ) aNextSalary on aNextSalary.row_num =  ctr.row_num + 1
 GO

 -- example 4--------------
 -- RANK and DENSE_RANK example 
 -- RANK: 1,1,1,1,5,5,5,5,5,10,10.....; DENSE_RANK: 1,1,1,1,2,2,2,2,2,3,3.....


SELECT e.FirstName,
	   e.LastName,
	   e.Salary, 
	   RANK() OVER (ORDER BY e.salary) [rank], 
	   DENSE_RANK () OVER (ORDER BY e.salary) denseRank,
	   ROW_NUMBER () OVER (ORDER BY e.salary) rowNumber
  FROM Employees e  

-- example 5--------------

SELECT TOP(1) 
	   emp.FirstName,
	   emp.LastName
  FROM (SELECT e.FirstName,
			   e.LastName,
			   DENSE_RANK () OVER (ORDER BY e.salary) salary_rank 
          FROM Employees e) emp
  where emp.salary_rank = 3


-- example 6--------------


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

 -- example 7--------------
 
  SELECT e.EmployeeID,
		 e.FirstName,
		 e.LastName,
		 e.Salary, 
		 SUM(e.Salary) OVER (ORDER BY e.employeeID) sum_salary 
    FROM Employees e 
ORDER BY e.EmployeeID


-- example 8---------------
-- this example shows what is happening when we join with the same table  and why the table rows are so much replicated 
select  e.EmployeeID,
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
from (select emp.EmployeeID,
			 emp.DepartmentID,
			 emp.FirstName,
			 emp.LastName,
			 emp.Salary,
			 ROW_NUMBER() over (order by employeeID) row_num
		from Employees emp) e
inner join (select emp1.EmployeeID,
				   emp1.DepartmentID,
				   emp1.FirstName,
				   emp1.LastName,
				   emp1.Salary,
				   ROW_NUMBER() over (order by employeeID) row_num 
	    from Employees emp1)e1 on e1.DepartmentID = e.DepartmentID


-- example 9--------------
-- it calculates the average for each row till the last one 

select e.FirstName,
	   e.LastName,
	   e.Salary,
	   e.DepartmentID,
	   AVG(e.Salary) over(order by  e.Salary) average
  from Employees e

-- example 9--------------

select e.EmployeeID,
	   e.FirstName,
	   e.LastName,
	   e.Salary,
	   ROW_NUMBER() over (order by e.Salary) row_num,
	   count(*) over (order by e.Salary) row_num_with_count_over_clause,
	   AVG(e.Salary) over (order by e.Salary ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) avg_salary_one_row_before_and_after,
	   count(*) over (order by e.Salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) row_num_with_count_over_clause
  from Employees e
  
-- example 10--------------



SELECT e.FirstName,
	   e.LastName,
	   e.DepartmentID,
	   e.Salary,
	   row_number() over ( order by e.FirstName ) row_num,
	   rank() over (partition by e.DepartmentID order by e.FirstName ) rank_column
  FROM Employees e
  ORDER BY e.DepartmentID
  
-- example 11--------------
 select oe.FirstName,oe.LastName,oe.DepartmentID,oe.Salary,oe.rank_column from 
(SELECT e.FirstName,
	   e.LastName,
	   e.DepartmentID,
	   e.Salary,
	   dense_rank() over (partition by e.DepartmentID order by e.Salary ) rank_column
  FROM Employees e) oe
  where oe.rank_column = 3
  


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				WITH 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO

WITH cte_filter_by_count 
AS 
(
   SELECT DepartmentID, 
		  COUNT(*) peoplePerGroup
   FROM Employees e
   GROUP BY DepartmentID
   HAVING COUNT(*) > 10
)
SELECT * FROM cte_filter_by_count

GO

WITH CTE_filter_first_names 
AS
(
      SELECT e.FirstName, 
		     e.LastName 
        FROM Employees e
  INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
       WHERE d.Name = 'Engineering'
)
 SELECT f.FirstName FROM CTE_filter_first_names f 
 GO

-- in this case the name of params does not have to be the same as the names of the colums , just the count must be the same 
WITH CTE_filter_by_name(firstname, lastname)
AS
(
	SELECT e.FirstName,e.LastName FROM Employees e
)
 select firstname from CTE_filter_by_name

GO	


-- another example
 WITH CTE_Employee_Count(departmentID,employee_count_per_department)
AS
(
	SELECT e.DepartmentID, COUNT(*) total_Count_Per_Department 
	FROM Employees e
	GROUP BY DepartmentID
)

SELECT e.FirstName,e.LastName,d.[Name],ec.employee_count_per_department 
FROM Employees e
INNER JOIN CTE_Employee_Count ec ON EC.departmentID = e.DepartmentID
INNER JOIN Departments d ON D.DepartmentID = e.DepartmentID
ORDER BY employee_count_per_department

select e.FirstName from Employees e
union all
select LastName from Employees




 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 																				VIEW (virtual table based on a SELECT query)
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO

  CREATE OR ALTER VIEW CTE_MyOwnFilter
  AS
(
      SELECT e.FirstName, 
		     e.LastName 
        FROM Employees e
  INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
       WHERE d.Name = 'Engineering'
)
GO
  SELECT * FROM CTE_MyOwnFilter

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 																				TEMPORARY TABLES(Local and Global Examples)
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1 - Local Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||
CREATE TABLE #PersonDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO #PersonDetails
VALUES
('Petko'),
('Ivan'),
('Georgi')

SELECT * FROM tempdb..sysobjects

SELECT [NAME] FROM tempdb..sysobjects
WHERE NAME LIKE '%#PersonDetails%'
GO
-- insert in already created temp table
  insert into #PersonDetails
  select FirstName from Employees
 select * from #PersonDetails
DROP TABLE IF EXISTS #PersonDetails
 -- insert in # temp table with no need of creating
 go
 select *
 INTO #TEMP_TABLE 
 from #PersonDetails

 SELECT * FROM #TEMP_TABLE
	DROP TABLE IF EXISTS #TEMP_TABLE


-- WHEN TEMPORARY TABLE  is inside STORED PROCEDURE get dropped once this SP complete it's execution 
GO
CREATE OR ALTER PROCEDURE SP_LocalTemporaryTable
AS
BEGIN
  CREATE TABLE #PersonDetails( 
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(50)
  )
  INSERT INTO #PersonDetails
  VALUES
  ('Petko'),
  ('Ivan'),
  ('Georgi')

  SELECT * FROM #PersonDetails
END

EXECUTE SP_TemporaryTable

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2 - Global Temporary Table       |||||||||||||||||||||||||||||||||||||||||||||||||

CREATE TABLE ##EmployeeDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO ##EmployeeDetails
VALUES
('employee First'),
('employee Second'),
('employee Third')

select * from ##EmployeeDetails

GO
CREATE OR ALTER PROCEDURE SP_GlobalTemporaryTable
AS
BEGIN
  CREATE TABLE ##EmployeeDetails( 
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(50)
  )
  INSERT INTO ##EmployeeDetails
  VALUES
  ('Petko'),
  ('Ivan'),
  ('Georgi'),
  ('employee First'),
  ('employee Second'),
  ('employee Third')

  SELECT * FROM ##EmployeeDetails
END

EXECUTE SP_GlobalTemporaryTable


-- |||||||||||||||||||||||||||||||||||||||||||||||||        3 - Couple different examples       |||||||||||||||||||||||||||||||||||||||||||||||||


SELECT d.[Name],
	   d.DepartmentID, 
	   COUNT(*) totalEmployees 
  FROM Employees e
  join Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID
  HAVING COUNT(*) > 20

-- done with #temp_table
  select d.Name, e.DepartmentID, count(*) sum_people_per_department 
    into  #temp_petko_test
    from Employees e
    join Departments d on d.DepartmentID = e.DepartmentID
group by d.Name, e.DepartmentID

 select * from #temp_petko_test where sum_people_per_department > 20
  DROP TABLE #temp_petko_test

go
-- instead of having query like this with HAVING clause we can create VIEW or WITH or some other approaches
-- if we will use this query just once we dont need to create a view  that's why i will give another examples  futher down
GO
CREATE VIEW cte_another_version
AS
(
SELECT d.[Name],
	   d.DepartmentID, 
	   COUNT(*) totalEmployees 
  FROM Employees e
  join Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID
)
GO
SELECT * FROM cte_another_version WHERE totalEmployees > 20

--  COMMON TABLE EXPRESSION WITH 
WITH cte_count_per_dept([name] ,dept,total)
AS
(
SELECT d.[Name],
	   d.DepartmentID, 
	   COUNT(*) totalEmployees 
  FROM Employees e
  join Departments d on d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID
)
SELECT name,total FROM cte_count_per_dept WHERE total > 20

GO

 GO


 -- Table variable  - can be passed as param between stored procedures
 DECLARE @TableEmployeeCount TABLE(DepartmentName NVARCHAR(50), DepartmentId INT, TotalEmployees INT)

 INSERT @TableEmployeeCount
 SELECT d.[Name],
	    d.DepartmentID, 
	    COUNT(*) totalEmployees 
  FROM Employees e
  join Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID	

  SELECT DepartmentName,
		 TotalEmployees		
  FROM @TableEmployeeCount 
  WHERE TotalEmployees > 20	 


  -- DERIVED TABLE
  SELECT Emp_Table_Result.Name,Emp_Table_Result.totalEmployees FROM 
  (SELECT d.[Name],
	    d.DepartmentID, 
	    COUNT(*) totalEmployees 
  FROM Employees e
  join Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID) AS Emp_Table_Result
  WHERE Emp_Table_Result.totalEmployees > 20

  
 

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				SUBSTRING
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO
 -- what it does : 
 -- in the following examples extract 4096 characters as starting from 1 
 -- using coalesce it says if the variable inside is null it will return the string inside bettween quotes which is 'NULL',IF NOT  it will return the actuall value
 -- of the variable because that is what COALESCE does  - return the first value different than NULL

DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_location_code NVARCHAR(10)  SET @i_location_code = NULL
DECLARE @i_warehouse_code NVARCHAR(10) SET @i_warehouse_code = '34RREWR'



SELECT @v_log_info = SUBSTRING(
    'Procedure bmever.spe__GetContainerCount <'   
	+  '@i_location_code = ' + '''' + COALESCE(@i_location_code,'NULL') + ''''
	+ ', @i_warehouse_code = ' +  '''' + COALESCE(@i_warehouse_code,'NULL') + ''''
    + '>', 1, 4096);
	print @v_log_info

GO

DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_creation_dt  DATETIME ;  SET @i_creation_dt = '2017-06-14 09:13:02.150';
DECLARE @i_completion_dt DATETIME ; SET @i_completion_dt = '2017-06-14 09:15:56.490'
DECLARE @i_handling_user_code NVARCHAR(30) SET @i_handling_user_code = 'JDO'
DECLARE @i_task_status SMALLINT SET @i_task_status = 80


	SELECT @v_log_info = SUBSTRING(
    'Procedure spr__printing_report_data <'   
	+  '@i_creation_dt = ' + COALESCE(CAST(@i_creation_dt AS NVARCHAR(50)),'NULL')
	+ ', @i_completion_dt = ' + COALESCE(CAST(@i_completion_dt AS NVARCHAR(50)),'NULL')
    + ', @i_handling_user_code = ' + '''' + COALESCE(@i_handling_user_code, 'NULL') + ''''
	+ ', @i_task_status = ' + COALESCE(CAST(@i_task_status AS NVARCHAR(20)),'NULL')
	+ '>', 1, 4096);

	print @v_log_info

-- this is just to demonstrate how to escape single quotes
GO
DECLARE @test_print NVARCHAR(2048);   SET @test_print = '';
DECLARE @test_var nvarchar(30) set @test_var = 'first_print_message'
SELECT @test_print = SUBSTRING('this is test print :<' + '@test_var = ' + ' ''   ' + COALESCE(@test_var,'null')+ '''',1,300)
print @test_print


GO
DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_first_number INT SET @i_first_number = 50
DECLARE @i_second_number INT SET @i_second_number = 60
DECLARE @o_sum_two_numbers INT SET @o_sum_two_numbers = @i_first_number +@i_second_number
DECLARE @i_final_message NVARCHAR(50) SET @i_final_message = 'FINAL'
SELECT @v_log_info = REPLACE(
      'Procedure bmever.cap__get_sum_of_two_numbers' +
      ' <@i_first_number = ' + RTRIM(COALESCE(CAST(@i_first_number AS NVARCHAR(20)), '<null>')) +
      ', @i_second_number = ' + RTRIM(COALESCE(CAST(@i_second_number AS NVARCHAR(20)), '<null>')) +
      ', @o_sum_two_numbers = ' + RTRIM(COALESCE(CAST(@o_sum_two_numbers AS NVARCHAR(20)), '<null>')) + 
	  ', @i_final_message = ' + '''' + RTRIM(COALESCE(@i_final_message, '<null>')) + '''' +
      '>', '''<null>''', 'NULL');
	  print @v_log_info
GO

DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_first_number INT SET @i_first_number = 50
DECLARE @i_second_number INT SET @i_second_number = 60
DECLARE @o_sum_two_numbers INT SET @o_sum_two_numbers = @i_first_number +@i_second_number


SELECT @v_log_info = SUBSTRING(
    'Procedure spe__get_container_count <'   
	+  '@i_first_number = ' + COALESCE(CAST(@i_first_number AS NVARCHAR(20)),'NULL')
	+ ', @i_second_number = ' + COALESCE(CAST(@i_second_number AS NVARCHAR(20)),'NULL')
    + ', @o_sum_two_numbers = ' + COALESCE(CAST(@o_sum_two_numbers AS NVARCHAR(20)),'NULL')
	+ '>', 1, 4096);
	print @v_log_info
GO

DECLARE @i_warehouse_code NVARCHAR(10) SET @i_warehouse_code = '34RREWR'
SELECT COALESCE(@i_warehouse_code,'NULL')

DECLARE @WHATEVER NVARCHAR(MAX) SET @WHATEVER = ''
SELECT @WHATEVER = SUBSTRING('Name = ' + '  ''' + 'ivan' + ' ',1,4096)
PRINT @WHATEVER


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				COALEASCE
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO 
 -- what it does : 
 -- return the first value which is NOT NULL

DECLARE @First NVARCHAR(MAX) SET @First = NULL
DECLARE @InBetween nvarchar(max) 
DECLARE @Second NVARCHAR(MAX) SET @Second = 'SECOND'
DECLARE @Third NVARCHAR(MAX) SET @Third = 'THIRD' 
 SELECT COALESCE(@First,@InBetween,@Second,@Third)



DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_first_option_null_value nvarchar(50)   SET @i_first_option_null_value = null;
DECLARE @i_secon_option_empthy_string nvarchar(50)   SET @i_secon_option_empthy_string = '';

-- in first option on the table column the result will be "the result is <null>"
SELECT @v_log_info = (COALESCE(@i_first_option_null_value,'<null>'))
SELECT CONCAT('the result is ', @v_log_info)
-- in second option on the table column the result will be "the result is "
SELECT @v_log_info = (COALESCE(@i_secon_option_empthy_string,'<null>'))
SELECT CONCAT('the result is ', @v_log_info)
-- that is the difference bettween null and string empthy 




 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				 @@ROWCOUNT
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO
  -- what it does : 
 -- it shows the count of the rows 
 select e.* from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT

select top 2 * from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT

select top 1 * from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT



 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--      																		MIX
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO
  -- what it does : 
 -- temp table with name 
 
 WITH cte_customWiew AS
 (
	SELECT * , ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY e.employeeID ) AS rownumber FROM Employees e
 )

 SELECT * FROM cte_customWiew
 

 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				TRY - CATCH
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

 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				UNION and UNION ALL
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

go
WITH cte_first_test(first_name, job_title)
AS
(
	SELECT e.FirstName,e.JobTitle FROM Employees e
), cte_second_test(first_name2,job_title2)
AS
(
	 SELECT e2.FirstName,e2.JobTitle FROM Employees e2
)

-- with UNION ALL we get all the records  and in this case they will be duplicated
-- select * from cte_first_test
-- union ALL
-- select * from cte_second_test

 -- in this case we will get only the Unique records who are not duplicated and perform DISTINCT SORT
 SELECT * FROM cte_first_test 
 UNION 
 SELECT * FROM cte_second_test

 select * from Employees



 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				CASE 
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


USE UserInfo
GO

 SELECT e.FirstName,e.LastName,e.Salary,
	   CASE	
       WHEN e.salary BETWEEN 100 AND 200 THEN 'low'
	   WHEN e.Salary BETWEEN 200 AND 400 THEN 'medium'
	   WHEN e.Salary  > 400				 THEN 'high'
	   ELSE 'ERROR'
	   END AS [SALARY DESCRIPTION]
	  
FROM UserInfoTable e
ORDER BY FirstName


     SELECT e.FirstName,e.LastName,e.Salary,
	   CASE	e.Salary
       WHEN 100 THEN 'HUNDRED'
	   WHEN 400 THEN 'FOUR_HUNDRED'
	   WHEN 500 THEN 'FIVE_HUNDRED'
	   ELSE 'DEFAULT'
	   END AS [SALARY DESCRIPTION]
FROM UserInfoTable e
ORDER BY FirstName

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				ISNULL 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use SoftUni
GO
CREATE OR ALTER PROCEDURE SP_TEST
(
@test_param INT = 0
)
AS
BEGIN
SELECT e.FirstName,e.LastName FROM Employees e
WHERE (ISNULL(@test_param , 0) = 0  OR (e.DepartmentID = @test_param))
END

exec SP_TEST @test_param = 3
select e.FirstName,e.LastName from Employees e where e.DepartmentID = '3'
select e.DepartmentID from Employees e where e.FirstName = guy

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				LEAD 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
select e.EmployeeID,
	   e.[row_number],
	   e.FirstName, 
	   e.LastName,
	   e.Salary,
	   e.next_row_salary,
	   e.column_difference
from (select emp.EmployeeID,
			 ROW_NUMBER() over (order by emp.EmployeeID) [row_number],
			 emp.FirstName,
			 emp.LastName,
			 emp.Salary,
			 LEAD(emp.Salary) over (order by emp.EmployeeID) as next_row_salary,
			 (emp.Salary - LEAD(emp.Salary) over (order by emp.EmployeeID)) column_difference
		from Employees emp) e

GO

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
			   WHERE ie.EmployeeID = emp.EmployeeID + 1)			   AS next_salary,
             (emp.Salary - (SELECT e1.Salary 
						      FROM Employees e1 
							 WHERE e1.EmployeeID = emp.EmployeeID + 1)) AS column_difference
		FROM Employees AS emp ) e


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
			  FROM Employees emp) as ctr 
 INNER JOIN (SELECT e.Salary, 
					e.row_num
	           FROM (SELECT emp.Salary,
							ROW_NUMBER() OVER (ORDER BY employeeID) row_num
					   FROM Employees emp) e ) aNextSalary on aNextSalary.row_num =  ctr.row_num + 1

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				NTILE() 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

create table  #temp
(
StudentID char(2),    
Marks  int
) 
insert #temp  values('S1',75 ) 
insert #temp  values('S2',83)
insert #temp  values('S3',91)
insert #temp  values('S4',83)
insert #temp  values('S5',93 ) 


select NTILE(2) over(order by Marks),*
from #temp
order by Marks

SELECT e.FirstName,
	   e.LastName,
	   e.Salary,
	   NTILE(3) over (partition by e.Salary order by e.salary) ntile_column			 
  FROM Employees e