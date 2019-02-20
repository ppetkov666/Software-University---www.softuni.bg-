CREATE VIEW V_EmployeeNameJobTitle 
AS
SELECT FirstName +' '+ ISNULL(MiddleName,'') +' '+ LastName AS [FullName],
	   JobTitle AS 'Job Title'
FROM Employees 
GO
SELECT * FROM V_EmployeeNameJobTitle