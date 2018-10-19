
/*****************************************************
Example 1.	
******************************************************/

SELECT * FROM Employees
SELECT * FROM Departments
SELECT * FROM Towns
SELECT * FROM Addresses

/*****************************************************
Example 2.	
******************************************************/

SELECT FirstName,LastName, 
	   Addresses.AddressText AS [Address],
	   Towns.[Name] AS [Town],
	   Departments.[Name] AS [Department]
FROM Employees
JOIN Addresses
ON Employees.AddressID = Addresses.AddressID
JOIN Towns
ON Employees.AddressID = Towns.TownID
JOIN Departments
ON Employees.DepartmentID = Departments.DepartmentID
WHERE Departments.DepartmentID =  (SELECT DepartmentID FROM Departments
								   WHERE Departments.[Name] = 'Production')

/*****************************************************
Example 3.	
******************************************************/

SELECT FirstName + ' ' + LastName AS [FullName]
INTO EmployeeNames 
FROM Employees
DROP TABLE EmployeeNames

/*****************************************************
Example 4.	
******************************************************/

SELECT *
FROM Peaks AS P
JOIN Mountains AS M
ON P.MountainId = M.Id

/*****************************************************
Example 5.	
******************************************************/

CREATE TABLE Countries(
		CountryID INT NOT NULL IDENTITY,
		[Name] NVARCHAR(50)

		CONSTRAINT PK_Contries
		PRIMARY KEY (CountryID)
)

CREATE TABLE Towns(
		TownID INT NOT NULL IDENTITY,
		[Name] NVARCHAR(50) NOT NULL,
		CountryID INT NOT NULL

		CONSTRAINT PK_Towns
		PRIMARY KEY (TownID)

		CONSTRAINT FK_Towns_Countries
		FOREIGN KEY(CountryID)
		REFERENCES Countries(CountryID)		
)


CREATE TABLE Employees(
		EmployeeID INT NOT NULL,
		[Name]	NVARCHAR(32) NOT NULL

		CONSTRAINT PK_Employees
		PRIMARY KEY (EmployeeID)
)


CREATE TABLE Projects(
		     ProjectID INT NOT NULL,
		     [Name]	NVARCHAR(32) NOT NULL,
  CONSTRAINT PK_Projects
 PRIMARY KEY (ProjectID)
)
 -- this is normal scenario but this time i will give another example
		--CONSTRAINT FK_Projects_Employees
		--FOREIGN KEY (EmployeeID)
		--REFERENCES Employees(EmployeeID)	

/*****************************************************
Example 6.	
******************************************************/

CREATE TABLE EmployeesProjects(
		EmployeeID INT NOT NULL,
		ProjectID  INT NOT NULl

		CONSTRAINT PK_EmployeesProjects
		PRIMARY KEY (EmployeeID, ProjectID),

		CONSTRAINT FK_EmployeesProjects_Employees
		FOREIGN KEY (EmployeeID) 
		REFERENCES Employees(EmployeeID),

		CONSTRAINT FK_EmployeesProjects_Projects
		FOREIGN KEY (ProjectID) 
		REFERENCES Projects(ProjectID)
)

/*****************************************************
Example 7.	
******************************************************/

INSERT INTO Employees
VALUES
(1,'PETKO'),
(2,'IVAN'),
(3,'GEORGI')

INSERT INTO Projects
VALUES
(1,' MS PROJECT'),
(2,'DATABASE PROJECT'),
(3,'CLASS PROJECT')

INSERT INTO EmployeesProjects
VALUES
(1,2),
(1,3),
(2,2),
(2,3)

/*****************************************************
Example 8.	
******************************************************/

SELECT E.Name,P.Name FROM Employees AS E
JOIN EmployeesProjects
ON E.EmployeeID = EmployeesProjects.EmployeeID 
join Projects AS P
on P.ProjectID = EmployeesProjects.ProjectID

SELECT * FROM Projects
SELECT * FROM EmployeesProjects

/*****************************************************
Example 9.	
******************************************************/
GO
CREATE OR ALTER FUNCTION udf_ProjectWeeks(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN 
	DECLARE @ProjectInfo INT; 
		IF	(@EndDate IS NULL)
		BEGIN
		SET @EndDate = GETDATE();
		END
	SET @ProjectInfo = DATEDIFF(WEEK, @StartDate, @EndDate);
	RETURN @ProjectInfo
END
GO
SELECT StartDate,
	   EndDate,
	   dbo.udf_ProjectWeeks(StartDate,EndDate) AS [CustomFunction_Column]
FROM Projects
/*****************************************************
Example 9.	
******************************************************/
GO
CREATE OR ALTER PROCEDURE usp_GetSeniorityTime
AS
DECLARE @TodayDate DATETIME = GETDATE()
	SELECT * 
	FROM Employees
	WHERE DATEDIFF(YEAR,HireDate, @TodayDate) > 17

EXEC dbo.usp_GetSeniorityTime
/*****************************************************
Example 10.	
******************************************************/
GO
         CREATE OR 
ALTER PROCEDURE usp_GetSeniorityTime
             AS
        DECLARE @TodayDate DATETIME = GETDATE()
         SELECT 
		        e.FirstName,
				e.LastName, 
				DATEDIFF(YEAR,HireDate, @TodayDate) AS Years
		   FROM Employees AS e
	      WHERE (DATEDIFF(YEAR,HireDate, @TodayDate) > 17)
	   ORDER BY HireDate
           EXEC dbo.usp_GetSeniorityTime

/*****************************************************
Example 11.	
******************************************************/
GO
         CREATE OR 
ALTER PROCEDURE usp_GetSeniorityTime(@Years INT = 5)
             AS
        DECLARE @TodayDate DATETIME = GETDATE()
         SELECT 
		        e.FirstName,
				e.LastName, 
				DATEDIFF(YEAR,HireDate, @TodayDate) AS Years
		   FROM Employees AS e
	      WHERE (DATEDIFF(YEAR,HireDate, @TodayDate) > @Years)
	   ORDER BY HireDate

           EXEC dbo.usp_GetSeniorityTime 18

/*****************************************************
Example 12.	
******************************************************/
GO
CREATE OR ALTER 
      PROCEDURE udp_SumTwoNumbers
					@FirstNumber INT,
				    @SecondNumber INT,
					@Result INT  OUTPUT
             AS 
			 SET @Result = @FirstNumber +@SecondNumber
-- if i execute the last three rows separatelly will break , 
-- but if do it at once will work
DECLARE @Answer INT 
EXEC udp_SumTwoNumbers 5,6,@Answer OUTPUT
SELECT 'THE RESULT IS: ', @Answer 

/*****************************************************
Example 13.	
******************************************************/	
GO

          CREATE OR 
 ALTER PROCEDURE udp_AssingProjects(@EmployeeID INT, @ProjectID int)
               AS 
            BEGIN 
	      DECLARE @maxProjectCountSToAssign INT =  3;
	      DECLARE @employeeProjectsCount INT = (
		   SELECT COUNT(*) 
		     FROM EmployeesProjects  ep 
		    WHERE ep.EmployeeID = @EmployeeID)
BEGIN TRANSACTION 
      INSERT INTO EmployeesProjects(EmployeeID,ProjectID)
           VALUES (@EmployeeID,@ProjectID)
		       IF (@employeeProjectsCount > @maxProjectCountSToAssign)
		    BEGIN
		RAISERROR ('Too Many Projects',16, 1);
		 ROLLBACK
		   RETURN;
		      END
			 ELSE
		   COMMIT
              END

SELECT * FROM EmployeesProjects
EXEC udp_AssingProjects 2,5
EXEC udp_AssingProjects 2,6
EXEC udp_AssingProjects 2,7
EXEC udp_AssingProjects 2,8
EXEC udp_AssingProjects 2,9

/*****************************************************
Example 14.	
******************************************************/	
GO
CREATE OR ALTER PROCEDURE udp_WithdrawMoney(@AccountID int, @Amount DECIMAL)
AS
BEGIN
	UPDATE Accounts
	SET Ballance = Ballance - @Amount
	WHERE id = @AccountID
	BEGIN TRANSACTION
	IF Ballance < 0
	BEGIN
		RAISERROR('INVALID TRANSACTION',16,1)
		ROLLBACK
		RETURN;
	END

	IF @@ROWCOUNT <> 1
	BEGIN 
		RAISERROR('INVALID ACCOUNT',16,2)
		ROLLBACK
		RETURN;
	END
	ELSE 
		COMMIT
	
 END

/*****************************************************
Example 15.	
******************************************************/

DECLARE @EmployeeNumbers INT = (
SELECT COUNT(EmployeeID) 
FROM Employees AS e 
WHERE e.MiddleName is NULL)

SELECT @EmployeeNumbers

/*****************************************************
Example 16.	
******************************************************/

GO
CREATE TRIGGER tr_TownsUpdate  ON Towns FOR UPDATE
AS
BEGIN TRANSACTION 
	IF (EXISTS(
		SELECT * FROM inserted 
		WHERE (Name IS NULL OR LEN(Name) = 0 )))
	BEGIN
		RAISERROR ('The Name cannot be Null',16,1)
		ROLLBACK
		RETURN;
	END
END
-- alter table with constraint looks simular but it is
--different
GO
ALTER TABLE Towns
ADD CONSTRAINT CHK_NameOfTheCity CHECK(LEN([Name]) > 2)

UPDATE Towns 
SET Name = ''
WHERE TownID = 1;

/*****************************************************
Example 17.	
******************************************************/

CREATE TABLE Accounts(
Username varchar(10) NOT NULL PRIMARY KEY,
[Password] varchar(20) NOT NULL,
Active char(1) NOT NULL DEFAULT 'Y'
)

GO
CREATE TRIGGER tr_AccountsDelete ON Accounts
INSTEAD OF DELETE
AS
BEGIN
	UPDATE a SET Active = 'N'
	FROM Accounts AS a 
	JOIN DELETED AS d  ON d.Username = a.Username
	WHERE a.Active = 'Y'
END

/*****************************************************
Example 18.	
******************************************************/

SELECT IS_MEMBER('db_owner')

/*****************************************************
Example 19.	
******************************************************/

GO

CREATE TABLE #Persons(
		PersonsID INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL
)
INSERT INTO #Persons 
VALUES
('petko','petkov'),
('ivan','ivanov'),
('georgi','georgiev')

GO

CREATE PROCEDURE udp_CreateTempTableAndDisplayIt
AS
BEGIN
	CREATE TABLE #Persons(
		PersonsID INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL
)
	INSERT INTO #Persons 
			VALUES
				('petko','petkov'),
				('ivan','ivanov'),
				('georgi','georgiev')

	SELECT * FROM #Persons
END
GO
EXEC udp_CreateTempTableAndDisplayIt

select name from tempdb..sysobjects
where name like '#Persons%'