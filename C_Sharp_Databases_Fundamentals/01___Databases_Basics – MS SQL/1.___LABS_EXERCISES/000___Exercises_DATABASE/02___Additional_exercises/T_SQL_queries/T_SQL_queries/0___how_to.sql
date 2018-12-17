

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             1
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
 -- third option - but this time we will take 7-th highest salary BUT the second person with 7th highes salary 
 
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
	
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             2
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

																														-- HOW TO take all managers of particular employee
  -- first option just shows each employee with his manager 
	select * from Employees
	GO 
	
	 SELECT e.EmployeeID,
					e.FirstName,
					e.LastName,
					e.ManagerID,
					m.EmployeeID,
					m.EmployeeID as 'manager ID',
					m.FirstName,
		 			m.LastName,
	 				m.ManagerID as 'his manager ID'
     FROM Employees AS e
     JOIN Employees AS m ON m.EmployeeID= e.ManagerID
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
		 JOIN emp_cte cte ON cte.ManagerID = e.EmployeeID
		)

	 SELECT emp_table.EmployeeID,
					emp_table.FirstName,
					emp_table.LastName,
					ISNULl(mngr_table.FirstName +' '+ mngr_table.LastName,'no Boss') AS 'manager' 
	   FROM emp_cte emp_table
		 JOIN emp_cte mngr_table ON mngr_table.EmployeeID = emp_table.ManagerID
-- further down i will break line by line how this recursive cte works
-- step 1 -- execute first select statement ANCHOR and we take manager id == 16 to step 2
SELECT emp.EmployeeID,
				  emp.FirstName,
				  emp.LastName,
		 	 	  emp.ManagerID		 
		 FROM Employees emp
	  WHERE emp.EmployeeID = 1
-- this is the result set:
-- 1	Guy	Gilbert	16

-- step 2 - execute second select statement RECURSIVE MEMBER without join just with where clause and managerID == 16
	 SELECT e.EmployeeID,
					e.FirstName,
					e.LastName,
					e.ManagerID 
		 FROM Employees e
		 --JOIN emp_cte cte ON cte.ManagerID = e.EmployeeID
		 where e.EmployeeID = 16

-- this is the result set:
-- 16	Jo	Brown	21

-- step 3 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
					e.FirstName,
					e.LastName,
					e.ManagerID 
		 FROM Employees e
		 where e.EmployeeID = 21

-- this is the result set:
-- 21	Peter	Krebs	148

-- step 4 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
					e.FirstName,
					e.LastName,
					e.ManagerID 
		 FROM Employees e
		 where e.EmployeeID = 148

-- this is the result set:
-- 148	James	Hamilton	109

-- step 5 - execute RECURSIVE MEMBER again

SELECT e.EmployeeID,
					e.FirstName,
					e.LastName,
					e.ManagerID 
		 FROM Employees e
		 where e.EmployeeID = 109

-- this is the result set:
-- 109	Ken	Sanches	null

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             3
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
--                                                                             4
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO find employees hired in last N-th month
-- in my case i will use years because my table data is little bit older

select * from 																								
(select e.FirstName,e.LastName,DATEDIFF(YEAR,HireDate,GETDATE()) as 'date diffrence in months' 
  from Employees e) emp
	where [date diffrence in months] < 15


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             5
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
--                                                                             6
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO find count of people grouped by departent and town name using 
																														-- 3 join statements  


	SELECT d.[Name],
				 t.[Name],
				 COUNT(*) AS 'count of people'
		FROM Employees e
		JOIN Departments d	ON d.DepartmentID = e.DepartmentID
		JOIN Addresses a		ON a.AddressID = e.AddressID
  	JOIN Towns t				ON t.TownID = a.TownID 
GROUP BY d.[Name],t.[Name]
ORDER BY COUNT(*) DESC







-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             7
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO 












-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             8
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO 
















-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             9
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO 

















-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             10
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																														-- HOW TO 











