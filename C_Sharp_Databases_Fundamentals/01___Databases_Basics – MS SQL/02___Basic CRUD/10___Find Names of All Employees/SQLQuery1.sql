SELECT FirstName + ' ' + MiddleName + ' '+ LastName
AS 'FullName' 
FROM Employees
WHERE 
Salary = 12500 OR
Salary = 14000 OR
Salary = 23600 OR
Salary = 25000 
