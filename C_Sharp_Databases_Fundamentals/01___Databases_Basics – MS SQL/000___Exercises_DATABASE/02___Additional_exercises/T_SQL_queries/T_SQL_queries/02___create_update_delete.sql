


select * from Employees
USE SoftUni
CREATE INDEX ix_employees_salary ON Employees (Salary ASC)

drop index Employees.ix_employees_salary












SELECT * FROM UserInfoTable ORDER BY FirstName,LastName,Salary
CREATE DATABASE UserInfo
GO
USE UserInfo
go
CREATE TABLE UserInfoTable(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50),
LastName NVARCHAR(50)
)
GO 

ALTER TABLE UserInfoTable
ADD CONSTRAINT FirstName
CHECK(LEN(FirstName) > 1)

GO
ALTER TABLE UserInfoTable
ADD Salary INT
GO

UPDATE UserInfoTable
SET Salary = 600
WHERE Id = 6 AND LastName = 'PETKOV'
GO

INSERT INTO UserInfoTable
VALUES 
('PETKO','PETKOV',400),
('IVAN','IVANOV'),
('GEORGI','GEORGIEV')

INSERT INTO UserInfoTable
VALUES
('KALOYAN', NULL)

SELECT * FROM UserInfoTable

GO 

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE PeopleDataBase

CREATE TABLE People(
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(50) NOT NULL,
  Age INT NOT NULL,
  Country NVARCHAR(50) NOT NULL
)
ALTER TABLE People
  ADD Lastname NVARCHAR(50) NOT NULL
GO

  EXEC sp_rename 'People.Name', 'Firstname', 'COLUMN'
GO

  SELECT * FROM People
GO

  INSERT INTO People
    VALUES
      ('ivan',20,'BG','ivanov'),
        ('georgi',23,'USA','georgiev'),
        ('slav',22,'EU','slavov'),
        ('kaloyan',21,'ARG','tonev')
GO

  SELECT * FROM People
GO

  INSERT INTO People
  VALUES
    ('ivan',30,'BG','georgiev'),
    ('ivan',40,'USA','ivanov'),
    ('ivan',50,'AUS','stoqnov')
GO

ALTER PROCEDURE spe_PeopleGetByLastName 
(@LastName NVARCHAR(50))
AS
BEGIN
  SELECT * from People WHERE Lastname = @LastName
END
GO

  EXEC dbo.spe_PeopleGetByLastName IVANOV
GO

CREATE or alter PROCEDURE spe_InsertData 
(@Firstname NVARCHAR(50), 
 @LastName NVARCHAR(50), 
 @Age INT, 
 @Country NVARCHAR(50)) 
AS
BEGIN
  INSERT INTO People
  VALUES
  (@Firstname,
   @Age,
   @Country,
   @LastName)
END
GO

TRUNCATE TABLE People
GO

-- sql injection EXAMPLE
  TRUNCATE TABLE People--
SELECT COUNT(*) FROM People
WHERE Firstname = 'ivan';TRUNCATE TABLE People --' AND Lastname = 'ivanov';

-- -----------------------------------------------------------------------------------------------
CREATE DATABASE Joins_Test_DB
USE Joins_Test_DB

CREATE TABLE Users(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50),
Gender NVARCHAR(10),
Salary DECIMAL(16,4),
DepartmentId  INT 
)
CREATE TABLE Department(
Id INT PRIMARY KEY IDENTITY,
DepartmentName NVARCHAR(50),
[Location] NVARCHAR(50),
DepartmentHead NVARCHAR(50)
)

ALTER TABLE [Users]  WITH NOCHECK --(not checking existing rows before adding the constraint)
ADD  CONSTRAINT [fk__Users__Department] 
FOREIGN KEY([DepartmentId])
REFERENCES [Department] ([Id])

INSERT INTO Users
  VALUES
    ('emilia',    'female', NULL,null),
    ('josefine',  'female', NULL,null),
    ('ivan',      'male',     100,1),
    ('jeko',      'male',     200,2),
    ('georgi',    'male',     300,3),
    ('borislava',  'female',  300,3),
    ('mihaela',    'female',  300,2)
GO
    INSERT INTO Department
    VALUES
    ('Other','Sidney','Antony'),
    ('IT',      'new york',   'Bob'),
    ('HR',      'london',     'John'),
    ('TECH',    'tokio',     'Kriss'),
    
select * from Users u
join Department d ON d.Id = u.DepartmentId
select * from Department



ALTER TABLE Users
alter column DepartmentId int null

-- --------------------------------------------------------------------------------

CREATE DATABASE db_for_test_purposes
USE db_for_test_purposes
CREATE TABLE Employee(
  EmployeeId INT NOT NULL,  
  [Name] NVARCHAR(32),  
  ManagerId INT

  CONSTRAINT pk__Employee PRIMARY KEY (EmployeeId)
)

select * from Employee

ALTER TABLE Employee 
ADD CONSTRAINT fk__Employee__ManagerId 
FOREIGN KEY (ManagerId) 
REFERENCES Employee (EmployeeId)


INSERT INTO Employee VALUES
(1,'John',NULL),
(2,'Maya',6),
(3,'Silvia',6),
(4,'Ted',6),
(5,'Mark',6),
(6,'Greta',1)

-- -------------------------------------------------------------------------------
 CREATE DATABASE CoffeeDB
 

 CREATE TABLE Drinks(
 drink_id INT IDENTITY NOT NULL,
 [drink_name] NVARCHAR(50) NOT NULL,
 price DECIMAL(6,2)
 CONSTRAINT [PK_Drinks] PRIMARY KEY ([drink_id]), 
 )
 
 CREATE TABLE Users(
 [user_id] INT IDENTITY NOT NULL,
 [first_name] NVARCHAR(50) NOT NULL,
 [last_name] NVARCHAR(50),
 CONSTRAINT [PK_Users] PRIMARY KEY ([user_id]),
 )

 CREATE TABLE Quantities(
 [drink_id] INT ,
 [user_id] INT ,
 quantity DECIMAL(6,2) DEFAULT(0) NOT NULL 
 CONSTRAINT PK_Quantities PRIMARY KEY(drink_id,[user_id]),
 CONSTRAINT [fk__Quantities_Drinks] FOREIGN KEY(drink_id) REFERENCES Drinks(drink_id), 
 CONSTRAINT [fk__Quantities_Users] FOREIGN KEY([user_id]) REFERENCES Users([user_id]) 
)

 
 INSERT INTO Drinks
 VALUES
 ('coffee',0.30),
 ('tea',0.20),
 ('mineral water - 1.5L',0.80),
 ('Coca-Cola - 1.5L',1.20)
 

 INSERT INTO Users
 VALUES
 ('Jeko','Minkov'),
 ('Tihomir',''),
 ('Kaloyan',''),
 ('Petko','petkov')



 -- -----------
 select * from Quantities
 select * from Users


 

  -- ------------------------


  SELECT u.first_name,
         u.last_name,
         d.drink_name,
         q.quantity,
         d.price,
         d.price * q.quantity total
    FROM Quantities q
    JOIN Drinks d ON d.drink_id = q.drink_id
    JOIN Users u  ON u.[user_id] = q.[user_id]
ORDER BY u.first_name,d.drink_name DESC

  SELECT u.[user_name],
         d.drink_name,
         sum(d.price * q.quantity) total
    FROM Quantities q
    JOIN Drinks d ON d.drink_id = q.drink_id
    JOIN Users u  ON u.[user_id] = q.[user_id]
    group by u.user_name,d.drink_name
ORDER BY u.[user_name],d.drink_name DESC


-- -------------------------------------------------------------------------------
 CREATE DATABASE student_test_db
 

 CREATE TABLE Students(
 id INT IDENTITY NOT NULL,
 student_name NVARCHAR(50) NOT NULL
 CONSTRAINT [PK_students] PRIMARY KEY ([id]), 
 )
 
 CREATE TABLE Courses(
 id INT IDENTITY NOT NULL,
 course_name NVARCHAR(50) NOT NULL
 CONSTRAINT [PK_Courses] PRIMARY KEY ([id]),
 )

 CREATE TABLE StudentCourses(
 [student_id] INT NOT NULL,
 [course_id] INT NOT NULL 
 CONSTRAINT [fk__StudentCourses_Courses] FOREIGN KEY(course_id) REFERENCES Courses(id), 
 CONSTRAINT [fk__StudentCourses_Students] FOREIGN KEY(student_id) REFERENCES Students(id) 
)

