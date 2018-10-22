CREATE DATABASE UserInfo
GO
USE UserInfo

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
SET Salary = 100
WHERE FirstName = 'IVAN'
GO

INSERT INTO UserInfoTable
VALUES 
('PETKO','PETKOV'),
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

