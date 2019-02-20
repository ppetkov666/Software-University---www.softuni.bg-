/*****************************************************
Problem 1.	Records’ Count
******************************************************/

USE Gringotts
SELECT * FROM WizzardDeposits
SELECT COUNT(*) AS [Count]
FROM WizzardDeposits

/*****************************************************
Problem 2.	Longest Magic Wand
******************************************************/

SELECT MAX(MagicWandSize) AS [Longest magic wand]
FROM WizzardDeposits

/*****************************************************
Problem 3.	Longest Magic Wand per Deposit Groups
******************************************************/

SELECT DepositGroup, MAX(MagicWandSize) AS [Longest magic wand]
FROM WizzardDeposits
GROUP BY DepositGroup

/*****************************************************
Problem 4.	* Smallest Deposit Group per Magic Wand Size
******************************************************/
SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

/*****************************************************
Problem 5.	Deposits Sum
******************************************************/

SELECT DepositGroup,SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup


/*****************************************************
Problem 6.	Deposits Sum for Ollivander Family
******************************************************/

SELECT * FROM WizzardDeposits
-- Both solutions works
SELECT DepositGroup,SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup,MagicWandCreator
--HAVING MagicWandCreator = 'Ollivander family'

/*****************************************************
Problem 7.	Deposits Filter
******************************************************/

SELECT DepositGroup,SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
HAVING MagicWandCreator = 'Ollivander family'AND 
						  (SUM(DepositAmount)) < 150000
ORDER BY [TotalSum] DESC

/*****************************************************
Problem 8.	 Deposit Charge
******************************************************/

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS [MinDepositCharge]
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

/*****************************************************
Problem 9.	Age Groups
******************************************************/

SELECT 
	CASE 
		WHEN Age BETWEEN 0 AND 10  THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20  THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30  THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40  THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50  THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60  THEN '[51-60]'
		WHEN Age > 60				THEN '[61+]'
		END AS [Age Group], COUNT(*) AS [WizardCount]
FROM WizzardDeposits
GROUP BY 
		CASE 
		WHEN Age BETWEEN 0 AND 10  THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20  THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30  THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40  THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50  THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60  THEN '[51-60]'
		WHEN Age > 60				THEN '[61+]'
		END
-- ANOTHER SOLUTION 
SELECT e.[Age Group], COUNT(e.[Age Group])  AS [Count]
FROM 
	(SELECT 
	 CASE 
		WHEN Age BETWEEN 0 AND 10  THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20  THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30  THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40  THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50  THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60  THEN '[51-60]'
		WHEN Age > 60				THEN '[61+]'
	  --ELSE 'The Person is too old'
		END AS [Age Group]
FROM WizzardDeposits) AS e
GROUP BY e.[Age Group]

/*****************************************************
Problem 10.	First Letter
******************************************************/

SELECT DISTINCT LEFT(FirstName,1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
ORDER BY FirstLetter
-- ANOTHER SOLUTION 
SELECT LEFT(FirstName,1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName,1)
/*****************************************************
Problem 11.	Average Interest 
******************************************************/

select * from WizzardDeposits

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS [Average interest]
FROM WizzardDeposits
WHERE DepositStartDate >= '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired


/*****************************************************
Problem 12.	* Rich Wizard, Poor Wizard
******************************************************/
SELECT SUM(DifferenceTable.DiffrenceColum) 
FROM
(
SELECT (DepositAmount -
(SELECT DepositAmount FROM WizzardDeposits WHERE Id = Host.Id + 1)
) AS DiffrenceColum
FROM WizzardDeposits AS Host
) AS DifferenceTable

--ANOTHER SOLUTION
SELECT SUM(MainTable.Difference) FROM (
SELECT DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id) AS [Difference]
FROM WizzardDeposits) AS MainTable


/*****************************************************
Problem 13.	Departments Total Salaries
******************************************************/

USE SoftUni
SELECT DepartmentID, SUM(Salary) AS [TotalSalary]
FROM Employees
GROUP BY DepartmentID

/*****************************************************
Problem 14.	Employees Minimum Salaries
******************************************************/

SELECT DepartmentID, MIN(Salary) AS [MinSalary]
FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate >= '01/01/2000'
GROUP BY DepartmentID

/*****************************************************
Problem 15.	Employees Average Salaries
******************************************************/

SELECT * INTO EmployeesAverageSalary
FROM Employees
WHERE Salary > 30000

--SELECT * FROM EmployeesAverageSalary

DELETE FROM EmployeesAverageSalary
WHERE ManagerID = 42

UPDATE EmployeesAverageSalary
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS [AverageSalary] 
FROM EmployeesAverageSalary
GROUP BY DepartmentID


/*****************************************************
Problem 16.	Employees Maximum Salaries
******************************************************/

SELECT DepartmentID, MAX(Salary) AS [MaxSalary]
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

/*****************************************************
Problem 17.	Employees Count Salaries
******************************************************/
SELECT COUNT(Salary)
FROM Employees
WHERE ManagerID IS NULL

/*****************************************************
Problem 18.	*3rd Highest Salary
******************************************************/

SELECT DISTINCT DepartmentID,Salary 
FROM (
SELECT DepartmentID, Salary, 
		DENSE_RANK() OVER (PARTITION BY DepartmentId 
		ORDER BY Salary DESC) AS [SalaryRank]
FROM Employees) AS e
WHERE e.SalaryRank = 3

/*****************************************************
Problem 19.	**Salary Challenge
******************************************************/
SELECT TOP(10) FirstName,LastName,DepartmentID
FROM Employees AS e1
WHERE Salary >(

SELECT AVG(Salary)
FROM Employees AS e2
WHERE e1.DepartmentID = e2.DepartmentID
GROUP BY DepartmentID
)

select * from Employees
select FirstName,LastName, count(Salary) as ''from Employees
group by FirstName,LastName
having Salary > 30000




