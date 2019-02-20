/*****************************************************
Problem 1.	Employee Address
******************************************************/

  SELECT TOP(5)e.EmployeeID,
			   e.JobTitle,
			   e.AddressID,
			   a.AddressText 
    FROM Employees AS e
    JOIN Addresses AS a 
	  ON e.AddressID = a.AddressID
ORDER BY AddressID

/*****************************************************
Problem 2.	Addresses with Towns
******************************************************/
-- this is how we have to arrange our query
  SELECT TOP (50) FirstName, 
		 LastName,
		 t.[Name]        AS Town, 
		 adr.AddressText AS AddressText
    FROM Employees		 AS emp
    JOIN Addresses		 AS adr 
	  ON emp.AddressID = adr.AddressID
    JOIN Towns			 AS t
      ON adr.TownID = t.TownID
ORDER BY FirstName,LastName

/*****************************************************
Problem 3.	Sales Employee
******************************************************/

   SELECT e.EmployeeID,
          e.FirstName,
          e.LastName,
          D.Name
	 FROM Employees AS e
     JOIN Departments AS d 
	   ON (e.DepartmentID = d.DepartmentID AND d.Name = 'Sales')
 ORDER BY e.EmployeeID 

/*****************************************************
Problem 4.	Employee Departments
******************************************************/

SELECT TOP(5)e.EmployeeID,e.FirstName,e.Salary,d.Name AS [DepartmentName] 
     FROM Employees         AS e 
LEFT JOIN Departments       AS d ON d.DepartmentID = e.DepartmentID
    WHERE e.Salary > 15000
 ORDER BY e.DepartmentID

/*****************************************************
Problem 5.	Employees Without Project
******************************************************/

   SELECT TOP(3)e.EmployeeID,e.FirstName 
     FROM Employees         AS e 
LEFT JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
LEFT JOIN Projects          AS p ON p.ProjectID = ep.ProjectID 
    WHERE p.Name IS NULL
 ORDER BY EmployeeID

/*****************************************************
Problem 6.	Employees Hired After
******************************************************/

   SELECT e.FirstName,
          e.LastName,
          e.HireDate,
          d.[Name]    AS DeptName
     FROM Employees   AS e
     JOIN Departments AS d ON (e.DepartmentID = d.DepartmentID 
	  AND e.HireDate > '1/1/1999'
      AND d.[Name] IN('Sales', 'Finance'))
 ORDER BY e.HireDate; 

/*****************************************************
Problem 7.	Employees with Project
******************************************************/

 DECLARE @FormatedDate DATE 
     SET @FormatedDate = CONVERT(DATE,'13.08.2002',103)
  SELECT TOP(5)e.EmployeeID,e.FirstName,p.Name
    FROM Employees         AS e
    JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
    JOIN Projects          AS p  ON p.ProjectID = ep.ProjectID
   WHERE p.StartDate > @FormatedDate
     AND p.EndDate IS NULL
ORDER BY EmployeeID

/*****************************************************
Problem 8.	Employee 24
******************************************************/

    SELECT e.EmployeeID,
	       e.FirstName,
      CASE 
	  WHEN p.StartDate > '2005'
	  THEN NULL
	  ELSE p.Name
	   END AS ProjectName
      FROM Employees         AS e
 LEFT JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
 LEFT JOIN Projects          AS p ON p.ProjectID = ep.ProjectID
     WHERE E.EmployeeID = 24 

/*****************************************************
Problem 9.	Employee Manager
******************************************************/

  SELECT  e.EmployeeID,e.FirstName,e.ManagerID,m.FirstName
    FROM Employees AS e
    JOIN Employees AS m ON m.EmployeeID = e.ManagerID 
   WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

/*****************************************************
Problem 10.	Employee Summary
******************************************************/

         SELECT TOP (50) emp.EmployeeID, 
		        emp.FirstName + ' ' + emp.LastName   AS EmployeeName,
		        mgrs.FirstName + ' ' + mgrs.LastName AS ManagerName,
		        dept.[Name]  
           FROM Employees                            AS emp
LEFT OUTER JOIN Employees                            AS mgrs 
             ON mgrs.EmployeeID = emp.ManagerID
LEFT OUTER JOIN Departments                          AS dept 
             ON dept.DepartmentID = emp.DepartmentID
       ORDER BY emp.EmployeeID

/*****************************************************
Problem 11.	Min Average Salary
******************************************************/

  SELECT MIN(AverageSalaries.Average) 
    FROM 
 (SELECT AVG(Salary)   AS Average 
    FROM Employees
GROUP BY DepartmentID) AS AverageSalaries

/*****************************************************
Problem 12.	Highest Peaks in Bulgaria
******************************************************/

  SELECT c.CountryCode,m.MountainRange,p.PeakName,p.Elevation 
    FROM Countries          AS c
    JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
    JOIN Mountains          AS m  ON m.Id = mc.MountainId
    JOIN Peaks              AS p  ON p.MountainId = m.Id
   WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

/*****************************************************
Problem 13.	Count Mountain Ranges
******************************************************/

  SELECT c.CountryCode, COUNT(m.MountainRange) 
    FROM Countries AS c
    JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
    JOIN Mountains          AS m  ON m.Id = mc.MountainId
   WHERE mc.CountryCode IN ('US','RU','BG')
GROUP BY c.CountryCode

/*****************************************************
Problem 14.	Countries with Rivers
******************************************************/

   SELECT TOP(5)c.CountryName,r.RiverName 
     FROM Countries AS c
LEFT JOIN CountriesRivers AS cr  ON  cr.CountryCode = c.CountryCode
LEFT JOIN Rivers          AS r   ON r.Id = cr.RiverId
LEFT JOIN Continents      AS cnt ON cnt.ContinentCode = c.ContinentCode
    WHERE cnt.ContinentName = 'Africa'
 ORDER BY c.CountryName

/*****************************************************
Problem 15.	*Continents and Currencies
******************************************************/

      WITH CTE_CurrencyInfo(ContinentCode,CurrencyCode,Ccounter) 
	    AS (
    SELECT ContinentCode,CurrencyCode,COUNT(CurrencyCode)   AS Ccounter 
      FROM Countries
  GROUP BY ContinentCode,CurrencyCode
    HAVING COUNT(CurrencyCode) > 1)

    SELECT e.ContinentCode,cci.CurrencyCode,e.MaxCurrency 
	  FROM (
    SELECT ContinentCode,MAX(Ccounter) AS MaxCurrency
      FROM CTE_CurrencyInfo
  GROUP BY ContinentCode )   AS e
      JOIN CTE_CurrencyInfo  AS cci 
        ON cci.ContinentCode = e.ContinentCode 
       AND cci.Ccounter = e.MaxCurrency
  ORDER BY e.ContinentCode

/*****************************************************
Problem 16.	Countries without any Mountains
******************************************************/

   SELECT COUNT(*) 
     FROM Countries          AS c
LEFT JOIN MountainsCountries AS mc 
       ON mc.CountryCode = c.CountryCode
    WHERE mc.CountryCode IS NULL

/*****************************************************
Problem 17.	Highest Peak and Longest River by Country
******************************************************/

     SELECT TOP(5)c.CountryName,
            MAX(p.Elevation)   AS [HighestPeakElevation],
            MAX(r.[Length])    AS [LongestRiverLength]
       FROM Countries          AS c
  LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
  LEFT JOIN Peaks              AS p  ON p.MountainId = mc.MountainId
  LEFT JOIN CountriesRivers    AS cr ON cr.CountryCode = c.CountryCode
  LEFT JOIN Rivers             AS r  ON r.Id = cr.RiverId
   GROUP BY c.CountryName
   ORDER BY HighestPeakElevation DESC,
            LongestRiverLength   DESC,c.CountryName

/*****************************************************
Problem 18.	* Highest Peak Name and Elevation by Country
******************************************************/

        WITH CTE_CountriesInfo(
		     CountryName, 
             PeakName, 
		     Elevation, 
			 MountainRange) 
		  AS (
      SELECT c.CountryName,
			 p.PeakName,
			 MAX(p.Elevation),
			 m.MountainRange
        FROM Countries                           AS c
   LEFT JOIN MountainsCountries                  AS mc 
          ON  mc.CountryCode = c.CountryCode 
   LEFT JOIN Mountains                           AS m 
          ON m.Id = mc.MountainId
   LEFT JOIN Peaks                               AS p 
          ON p.MountainId = m.Id
    GROUP BY c.CountryName, P.PeakName,M.MountainRange 
	         )

      SELECT e.CountryName                       AS Country,
	  ISNULL (cci.PeakName,'(no highest peak)')  AS [Highest Peak Name],
	  ISNULL (cci.Elevation,'0')                 AS [Highest Peak Elevation],
	  ISNULL (cci.MountainRange,'(no mountain)') AS [Mountain]
        FROM (
      SELECT TOP(5)CountryName,MAX(Elevation)    AS MaxElevation
        FROM CTE_CountriesInfo
    GROUP BY CountryName)                        AS e
   LEFT JOIN CTE_CountriesInfo                   AS cci 
          ON cci.CountryName = e.CountryName 
         AND cci.Elevation = e.MaxElevation
    ORDER BY e.CountryName, cci.PeakName

-- THIS IS JUST HELP INFO TO NAVIGATE
select * from Countries
SELECT * FROM MountainsCountries
select * from Mountains
SELECT * FROM Peaks
