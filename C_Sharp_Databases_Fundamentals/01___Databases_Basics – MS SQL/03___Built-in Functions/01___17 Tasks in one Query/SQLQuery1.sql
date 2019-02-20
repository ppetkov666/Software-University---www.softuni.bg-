
/*****************************************************
Part I – Queries for SoftUni Database
Problem 1.	Find Names of All Employees by First Name
******************************************************/

SELECT FirstName,LastName 
FROM Employees
WHERE FirstName LIKE 'SA%'

/*****************************************************
Problem 2.	  Find Names of All employees by Last Name 
******************************************************/

SELECT FirstName,LastName 
FROM Employees
WHERE LastName LIKE '%ei%'

/*****************************************************
Problem 3.	Find First Names of All Employees 
******************************************************/

SELECT FirstName
FROM Employees
WHERE DepartmentID = 3 OR
	  DepartmentID = 10 OR
	  HireDate >= 1995 AND HireDate <= 2005
	  -- there is another solution also 
SELECT FirstName
FROM Employees
WHERE (DepartmentID = 3 OR DepartmentID = 10) AND
	   DATEPART(YEAR, HireDate)
	   BETWEEN 1995 AND 2005

/*****************************************************
Problem 4.	Find All Employees Except Engineers 
******************************************************/

SElECT FirstName, LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

/*****************************************************
Problem 5.	Find Towns with Name Length 
******************************************************/

SELECT [Name] FROM Towns
WHERE LEN(Name) = 5 OR
      LEN(Name) = 6
ORDER BY [Name]

/*****************************************************
Problem 6.	 Find Towns Starting With 
******************************************************/

SELECT * FROM Towns
WHERE SUBSTRING(Name,1,1) LIKE '[MKBE]'
-- there is also another solution using different method:
-- WHERE LEFT(Name,1) LIKE '[MKBE]'
ORDER BY [Name]

/*****************************************************
Problem 7.	 Find Towns Not Starting With 
******************************************************/

SELECT * FROM Towns
WHERE SUBSTRING(Name,1,1) NOT LIKE '[RBD]'
ORDER BY [Name]


/*****************************************************
Problem 8.	Create View Employees Hired After 2000 Year
******************************************************/
GO
CREATE VIEW V_EmployeesHiredAfter2000 
AS 
SELECT FirstName, LastName
FROM Employees
WHERE DATEPART(YEAR,HireDate) > 2000
GO
SELECT * FROM V_EmployeesHiredAfter2000
GO

/*****************************************************
Problem 9.	Length of Last Name 
******************************************************/

SELECT FirstName, LastName
FROM Employees
WHERE LEN (LastName) = 5

/*****************************************************
Part II – Queries for Geography Database 
Problem 10.	Countries Holding ‘A’ 3 or More Times 
******************************************************/

SELECT CountryName,IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode
-- this is solution for exactly 3 letters of 'A'
SELECT CountryName,IsoCode
FROM Countries
WHERE LEN(CountryName) - 3 = LEN(REPLACE(CountryName,'a',''))
ORDER BY IsoCode

/*****************************************************
Problem 11.	 Mix of Peak and River Names 
******************************************************/

--just a simple example what actualy i am doing
SELECT CONCAT(LEFT('PETKO',LEN('petko')- 1),'oktep') 

SELECT Peaks.PeakName,
	   Rivers.RiverName,
	   LOWER(CONCAT(LEFT(Peaks.PeakName,LEN(Peaks.PeakName)-1),Rivers.RiverName)) AS ONE
FROM Peaks
JOIN Rivers ON RIGHT(Peaks.PeakName, 1) = LEFT(Rivers.RiverName, 1)
ORDER BY ONE
-- there is another solution also with simple WHERE and without Join both tables
SELECT Peaks.PeakName,
	   Rivers.RiverName,
	   LOWER(CONCAT(LEFT(Peaks.PeakName,LEN(Peaks.PeakName)-1),Rivers.RiverName)) AS ONE
FROM Peaks,Rivers
WHERE RIGHT(PeakName,1) = LEFT(RiverName,1)
ORDER BY ONE


/*****************************************************
Part III – Queries for Diablo Database
Problem 12.	Games from 2011 and 2012 year 
******************************************************/

SELECT TOP(50)[Name], 
			  FORMAT(CAST([START] AS DATE),'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR,[START]) BETWEEN 2011 AND 2012
ORDER BY [Start],
		 [Name]
-- another solution which does not need CAST 
SELECT TOP(50)[Name], 
			  FORMAT([START],'yyyy-MM-dd') AS [Start]
FROM Games
WHERE DATEPART(YEAR,[START]) BETWEEN 2011 AND 2012
ORDER BY [Start],
		 [Name]

/*****************************************************
Problem 13.	 User Email Providers 
******************************************************/
-- for example petko666@gmail.com lenght = 18 - 9 = 9 
-- and RIGHT( petko666@gmail.com , 9) = gmail.com
SELECT Username,
	   RIGHT(Email,LEN(Email) - CHARINDEX('@',Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username

/*****************************************************
Problem 14.	 Get Users with IPAdress Like Pattern
******************************************************/
-- _ match one single character , 
-- % match everything 
SELECT Username,
       IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1_%._%.___'
ORDER BY Username

/*****************************************************
Problem 15.	 Show All Games with Duration and Part of the Day 
******************************************************/

SELECT [Name] AS [Game],
	   CASE	
       WHEN DATEPART(HOUR,Start) BETWEEN 0 AND 11 THEN 'Morning'
	   WHEN DATEPART(HOUR,Start) BETWEEN 12 AND 17 THEN 'Afternoon'
	   WHEN DATEPART(HOUR,Start) BETWEEN 18 AND 23 THEN 'Evening'
	   ELSE 'ERROR'
	   END AS [Part Of the Day],
	   CASE	
       WHEN Duration <= 3 THEN 'Extra Short'
	   WHEN Duration <= 4 AND Duration >= 6 THEN 'Short'
	   WHEN Duration > 6 THEN 'Long'
	   WHEN Duration IS NULL THEN 'Extra Long' 
	   ELSE 'ERROR'
	   END AS [Duration]
FROM Games
ORDER BY Name,
         [Duration],
		 [Part Of the Day]

/*****************************************************
Part IV – Date Functions Queries
Problem 16.	 Orders Table
******************************************************/

SELECT ProductName,
	   OrderDate,
	   DATEADD(DAY,3,OrderDate) AS [Pay Due],
	   DATEADD(Month,1,OrderDate) 
FROM Orders

/*****************************************************
Problem 17.	 People Table 
******************************************************/
CREATE TABLE People(
			 Id INT PRIMARY KEY  NOT NULL,
			 [Name] NVARCHAR(50) NOT NULL,
			 Birthdate DATETIME2 NOT NULL
)
INSERT INTO People
VALUES 
(1,	'Victor',	'2000-12-07 00:00:00.000'),
(2,	'Steven',	'1992-09-10 00:00:00.000'),
(3,	'Stephen',	'1910-09-19 00:00:00.000'),
(4,	'John',	'2010-01-06 00:00:00.000')

SELECT [Name],
	   DATEDIFF(YEAR,Birthdate,GETDATE()) AS [Age in Years],
	   DATEDIFF(MONTH,Birthdate,GETDATE()) AS [Age in Months],
	   DATEDIFF(DAY,Birthdate,GETDATE()) AS [Age in Days],
	   DATEDIFF(MINUTE,Birthdate,GETDATE()) AS [Age in Minutes] 

FROM People