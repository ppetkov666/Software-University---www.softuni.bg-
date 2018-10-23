USE SoftUni
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				GROUP BY 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 GO

  SELECT TOP (10) e.FirstName,
	     e.LastName,
	     e.DepartmentID,
	     e.Salary
    FROM Employees e
   WHERE Salary > (SELECT AVG(Salary) averageSalaryPerDepartment FROM Employees e1
   WHERE e.DepartmentID = e1.DepartmentID
GROUP BY DepartmentID
)
GO
SET STATISTICS TIME OFF
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

-- THIS IS SAME query but with over clause
SELECT e.FirstName,
	       e.LastName, 
		   e.Salary,
		   e.DepartmentID,
		   COUNT(*) OVER (PARTITION BY departmentId) total_each_department,
		   AVG(Salary) OVER (PARTITION BY departmentId) AVERAGE,
		   MIN(Salary) OVER (PARTITION BY departmentId) MINSALARY, 
		   MAX(Salary) OVER (PARTITION BY departmentId) MAXSALARY 
	  FROM Employees e 

  SELECT e.DepartmentID, COUNT(*) 
    FROM Employees e
GROUP BY e.DepartmentID
  HAVING count(*) > 10 

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				OVER 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

GO
 SELECT e.FirstName,
		e.LastName,
		e.Salary, 
		count(*) OVER (PARTITION BY departmentID ) PeoplePerDepartment 
   FROM Employees e

GO


GO
SELECT e.Salary,
	   (e.Salary + (SELECT e1.Salary FROM Employees e1 WHERE e1.EmployeeID = e.EmployeeID + 1)) salarysum,
	   ROW_NUMBER() OVER (ORDER BY EmployeeId) rowNumber
 FROM Employees e
 GO

SELECT e.FirstName,
	   e.LastName,
	   e.Salary, 
	   RANK() OVER (ORDER BY e.salary) [rank],
	   DENSE_RANK () OVER (ORDER BY e.salary) denseRank,
	   ROW_NUMBER () OVER (ORDER BY e.salary) rowNumber
  FROM Employees e  

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


  SELECT e.EmployeeID,
		 e.FirstName,
		 e.LastName,
		 e.Salary, 
		 SUM(e.Salary) OVER (ORDER BY e.employeeID) sumsalary 
    FROM Employees e 
ORDER BY e.EmployeeID

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				WITH 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO

WITH cte_filter_by_count 
AS 
(
   SELECT DepartmentID, COUNT(*) peoplePerGroup
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

-- TEMPORARY TABLE
SELECT d.[Name],d.DepartmentID, 
	   COUNT(*) totalEmployees 
  INTO #Temporary_Table 
  FROM Employees e
  join Departments d ON d.DepartmentID = e.DepartmentID
  GROUP BY d.[Name],d.DepartmentID

 SELECT Name, totalEmployees FROM #Temporary_Table
 WHERE totalEmployees > 20 

 GO
DROP TABLE #Temporary_Table

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

DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_location_code NVARCHAR(10)  SET @i_location_code = 'R43EF'
DECLARE @i_warehouse_code NVARCHAR(10) SET @i_warehouse_code = '34RREWR'

SELECT @v_log_info = SUBSTRING(
    'Procedure bmever.spe__GetContainerCount <'   
	+  '@i_location_code = ' + '''' + COALESCE(@i_location_code,'NULL') + ''''
	+ ', @i_warehouse_code = ' +  '''' + COALESCE(@i_warehouse_code,'NULL') + ''''
    + '>', 1, 4096);
	print @v_log_info

GO
DECLARE @v_log_info  NVARCHAR(2048);   SET @v_log_info = '';
DECLARE @i_first_number INT SET @i_first_number = 50
DECLARE @i_second_number INT SET @i_second_number = 60
DECLARE @o_sum_two_numbers INT SET @o_sum_two_numbers = @i_first_number +@i_second_number
SELECT @v_log_info = REPLACE(
      'Procedure bmever.cap__get_sum_of_two_numbers' +
      ' <@i_first_number = ' + RTRIM(COALESCE(CAST(@i_first_number AS NVARCHAR(20)), '<null>')) +
      ', @i_second_number = ' + RTRIM(COALESCE(CAST(@i_second_number AS NVARCHAR(20)), '<null>')) +
      ', @o_sum_two_numbers = ' + RTRIM(COALESCE(CAST(@o_sum_two_numbers AS NVARCHAR(20)), '<null>')) +
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

DECLARE @First NVARCHAR(MAX) SET @First = NULL
DECLARE @Second NVARCHAR(MAX) SET @Second = 'SECOND'
DECLARE @Third NVARCHAR(MAX) SET @Third = 'THIRD' 
 SELECT COALESCE(@First,@Third,@Second)






 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				 @@ROWCOUNT
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO

 select * from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT

select top 2 * from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT

select top 1 * from Employees e where e.FirstName like 'p%'
select @@ROWCOUNT


 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				STORED PROCEDURE
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO
 
  -- STORED PROCEDURE
 CREATE OR ALTER PROCEDURE UDP_Filter_people_per_department 
 AS
 BEGIN
     SELECT e.FirstName, 
		    e.LastName 
	   FROM Employees e
 INNER JOIN Departments d ON D.DepartmentID = E.DepartmentID
      WHERE d.Name = 'Engineering'
 END
 GO
 EXEC UDP_Filter_people_per_department
 
 GO
 
 -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				MIX
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO
 
 
 WITH cte_customWiew AS
 (
	SELECT * , ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY e.employeeID ) AS rownumber FROM Employees e
 )

 SELECT * FROM cte_customWiew
 

 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																				TRY - CATCH
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 GO  

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
