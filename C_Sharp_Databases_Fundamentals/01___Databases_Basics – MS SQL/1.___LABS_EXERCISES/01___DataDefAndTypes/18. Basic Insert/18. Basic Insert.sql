INSERT INTO Towns ([Name]) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

GO 
--Engineering, Sales, Marketing, Software Development, Quality Assurance

INSERT INTO Departments ([Name]) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')
GO

SELECT * FROM Employees
GO

ALTER TABLE Employees
ALTER COLUMN AddressId INT

INSERT INTO Employees 
(FirstName, MiddleName, LastName,JobTitle, DepartmentId, HireDate, Salary) 
VALUES
('Ivan','Ivanov','Ivanov','.NET Developer',4,CONVERT(DATETIME,'01/02/2013',103),3500.00),
('Petar','Petrov','Petrov','Senior Engineer',1,CONVERT(DATETIME,'02/03/2004', 103),4000.00),
('Maria','Petrova','Ivanova','Intern',5,CONVERT(DATETIME, '28/08/2016', 103),525.25),
('Georgi','Teziev','Ivanov','CEO',2,CONVERT(DATETIME, '09/12/2007', 103),3000.00),
('Peter','Pan','Pan','Intern',3,CONVERT(DATETIME,'28/08/2016',103),599.88)
GO

SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees