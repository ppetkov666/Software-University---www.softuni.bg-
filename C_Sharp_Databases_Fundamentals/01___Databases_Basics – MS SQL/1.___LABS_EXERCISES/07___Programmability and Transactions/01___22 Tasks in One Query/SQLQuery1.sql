
/*****************************************************
--Section I. Functions and Procedures
--Part 1. Queries for SoftUni Database
Problem 1. Employees with Salary Above 35000
******************************************************/


GO
CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT e.FirstName,e.LastName 
	FROM Employees AS e
	WHERE e.Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000

/*****************************************************
Problem 2. Employees with Salary Above Number
******************************************************/

GO
CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAboveNumber(@number DECIMAL(18,4))
AS
BEGIN
	SELECT e.FirstName,e.LastName 
	FROM Employees AS e
	WHERE e.Salary >= @number
END

EXEC usp_GetEmployeesSalaryAboveNumber 48100

/*****************************************************
Problem 3. Town Names Starting With
******************************************************/

GO
CREATE OR ALTER PROCEDURE usp_GetTownsStartingWith(@inputText VARCHAR(32))
AS
BEGIN
	SELECT [Name] 
		FROM Towns
		WHERE [Name] LIKE @inputText + '%'
END

EXEC usp_GetTownsStartingWith b

/*****************************************************
Problem 4. Employees from Town
******************************************************/

GO
CREATE OR ALTER PROCEDURE usp_GetEmployeesFromTown(@townName VARCHAR(32))
AS
BEGIN
	SELECT e.FirstName,e.LastName 
	FROM Employees AS e
	JOIN Addresses AS ad ON AD.AddressID = e.AddressID
	JOIN Towns AS t ON t.TownID = ad.TownID
	WHERE t.[Name] LIKE @townName + '%' 
END

EXEC usp_GetEmployeesFromTown sof

/*****************************************************
Problem 5. Salary Level Function
******************************************************/

GO
CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
BEGIN
	
	IF (@salary < 30000)
	BEGIN
		RETURN 'Low'
	END
	ELSE IF (@salary BETWEEN 30000 AND 50000)
	BEGIN
		RETURN 'Average'
	END
	ELSE 
	BEGIN
	RETURN 'High'
END 
GO
SELECT FirstName,LastName, dbo.ufn_GetSalaryLevel(Salary)
FROM Employees

/*****************************************************
Problem 6. Employees by Salary Level
******************************************************/

GO
CREATE OR ALTER PROCEDURE usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(7)) 
AS
BEGIN
	SELECT e.FirstName,e.LastName
	FROM Employees AS e
	WHERE dbo.ufn_GetSalaryLevel(e.Salary) = @SalaryLevel
END
EXEC usp_EmployeesBySalaryLevel 'High'

/*****************************************************
Problem 7. Define Function
******************************************************/

GO
CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT
BEGIN
	DECLARE @index INT = 1
	DECLARE @currentChar CHAR(1)
	DECLARE @isFound INT
	WHILE(@INDEX <= LEN(@word))
	BEGIN
		SET @currentChar = SUBSTRING(@word,@index,1)
		SET @isFound = CHARINDEX(@currentChar,@setOfLetters)
			IF(@isFound = 0)
			BEGIN
				RETURN 0;
			END		

		SET @INDEX +=1
	END
	
	RETURN 1;
END
GO
SELECT dbo.ufn_IsWordComprised('oistmiahf','sofia') 

/*****************************************************
Problem 8. * Delete Employees and Departments
******************************************************/

GO
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN

	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID 
					 FROM Employees 
					 WHERE DepartmentID = @departmentId)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID 
					FROM Employees 
					WHERE DepartmentID = @departmentId)

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID 
					FROM Employees 
					WHERE DepartmentID = @departmentId)

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT * 
	FROM Employees
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*)
	FROM Employees
	WHERE DepartmentID = @departmentId

END


/*****************************************************
Part 2. Queries for Bank Database
Problem 9. Find Full Name
******************************************************/
GO
CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT ah.FirstName + ' ' + ah.LastName
	FROM AccountHolders AS ah
END

EXEC usp_GetHoldersFullName

/*****************************************************
Problem 10. People with Balance Higher Than
******************************************************/
-- first solution
GO
CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan(@ballance DECIMAL(18,4))
AS
BEGIN
	SELECT ah.FirstName, ah.LastName
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	GROUP BY AH.FirstName,AH.LastName
	HAVING SUM(a.Balance) > @ballance 
END

EXEC usp_GetHoldersWithBalanceHigherThan 7000

-- second solution
GO
CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan(@ballance DECIMAL(18,4))
AS
BEGIN
	WITH CTE_AccountHolderBallance(ACcountHolderId, Ballance) 
	AS (
	SELECT  a.AccountHolderId, SUM(a.Balance) AS TotalBallance
	FROM Accounts AS a
	GROUP BY a.AccountHolderId)

	SELECT  ah.FirstName,ah.LastName
	FROM AccountHolders AS ah
	JOIN CTE_AccountHolderBallance AS c ON c.ACcountHolderId = ah.Id
	GROUP BY AH.FirstName,AH.LastName
	HAVING SUM(c.Ballance) > @ballance
END

EXEC usp_GetHoldersWithBalanceHigherThan 7000

	

/*****************************************************
Problem 11. Future Value Function
******************************************************/

GO
CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15,4), 
										 @interesRate FLOAT,
										 @years INT)
RETURNS DECIMAL(15,4)
BEGIN
	RETURN  @sum * POWER(1 + @interesRate,@years) 
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

/*****************************************************
Problem 12. Calculating Interest
******************************************************/

GO
CREATE OR ALTER PROCEDURE usp_CalculateFutureValueForAccount
						  (@accountID INT, 
						   @interestRate FLOAT)
AS
BEGIN
	SELECT a.Id, 
		   ah.FirstName,
		   ah.LastName,
		   a.Balance,
		   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate,5) 
		                AS [Balance in 5 years]
	FROM Accounts       AS a
	JOIN AccountHolders AS ah ON ah.Id = a.AccountHolderId
	WHERE a.Id = @accountID
END

EXEC usp_CalculateFutureValueForAccount 1,0.1

/*****************************************************
Part 3. Queries for Diablo Database
Problem 13. *Scalar Function: Cash in User Games Odd Rows
******************************************************/

GO
CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(50))
RETURNS TABLE
AS 
RETURN 
(
	SELECT SUM(e.Cash) AS [SumCash] FROM (
	SELECT ug.Cash , ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [RowNumber]
	FROM Games AS g
	JOIN UsersGames AS ug ON ug.GameId = g.Id
	WHERE g.Name = @gameName) AS e
	WHERE RowNumber % 2 = 1
) 

GO
SELECT * FROM dbo.ufn_CashInUsersGames('Lily Stargazer')

SELECT * FROM Games
SELECT * FROM UsersGames

/*****************************************************
Section II. Triggers and Transactions
Part 1. Queries for Bank Database
Problem 14. Create Table Logs
******************************************************/

CREATE TABLE Logs(
	LogId INT IDENTITY NOT NULL, 
	AccountId INT NOT NULL, 
	OldSum DECIMAL(15,4), 
	NewSum DECIMAL(15,4)
)
GO
CREATE OR ALTER TRIGGER tr_Accounts
ON Accounts
FOR UPDATE
AS
BEGIN
		DECLARE @accountID INT = (SELECT Id FROM inserted)
		DECLARE @oldSum DECIMAL(15,4) = (SELECT Balance FROM deleted)
		DECLARE @newSum DECIMAL(15,4) = (SELECT Balance FROM inserted)

		INSERT INTO Logs VALUES
		(@accountID, @oldSum,@newSum)
		
END

UPDATE Accounts SET Balance = 6666 WHERE Id = 2
SELECT * FROM Accounts
SELECT * FROM Logs
SELECT * FROM AccountHolders

/*****************************************************
Problem 15. Create Table Emails
******************************************************/

GO
CREATE TABLE NotificationEmails(
	Id INT IDENTITY NOT NULL, 
	Recipient INT NOT NULL, 
	[Subject] VARCHAR(64), 
	Body VARCHAR(MAX)
)
ALTER TABLE NotificationEmails
ADD CONSTRAINT PK_NotificationEmails PRIMARY KEY(Id)

GO
CREATE OR ALTER TRIGGER tr_Logs_NotificationEmails
ON Logs
FOR INSERT
AS
BEGIN
	INSERT INTO NotificationEmails
		VALUES
		-- the first entry is for Recipient column
         ((SELECT AccountId FROM inserted),
		 -- the second entry is for [Subject] column
         CONCAT('Balance change for account: '
		 ,(SELECT AccountId FROM inserted)),
		 -- the third entry is for Body column
		 -- FORMAT(GETDATE(), 'dd-MM-yyyy HH:mm') this is the other option to 
		 -- format the date
         CONCAT('On ', GETDATE(), 
		 ' your balance was changed from ',
               (
                   SELECT OldSum
                   FROM Logs
               ), ' to ',
               (
                   SELECT NewSum
                   FROM Logs
               ), '.')
         );
     END;
GO
INSERT INTO Logs(AccountId,OldSum,NewSum)
VALUES
(2,666,999)
SELECT * FROM NotificationEmails

/*****************************************************
Problem 16. Deposit Money
******************************************************/

GO
CREATE PROCEDURE usp_DepositMoney(
                 @accountId   INT,
                 @moneyAmount DECIMAL(15,4))
AS
BEGIN
	IF(@moneyAmount < 0)
		BEGIN
			RAISERROR('Negative Deposit Amount, Enter positive value', 16, 1);
		END;
	ELSE
		BEGIN
			IF(@accountId IS NULL  OR @moneyAmount IS NULL)
				BEGIN
					RAISERROR('Missing value', 16, 1);
				END;
		END;
         
	BEGIN TRANSACTION;
		UPDATE Accounts 
			SET Balance+=@moneyAmount
		    WHERE Id = @accountId;
				IF(@@ROWCOUNT < 1)
				BEGIN
					RAISERROR('Account doesn''t exists', 16, 1);
					ROLLBACK;
				END;
   COMMIT;
END;

/*****************************************************
Problem 17. Withdraw Money
******************************************************/

GO
CREATE PROCEDURE usp_WithdrawMoney(
                 @accountId   INT,
                 @moneyAmount DECIMAL(15,4))
AS
BEGIN
	IF(@moneyAmount < 0)
		BEGIN
			RAISERROR('Negative Withdraw Amount, Enter positive value', 16, 1);
		END;
	ELSE
		BEGIN
			IF(@accountId IS NULL OR @moneyAmount IS NULL)
				BEGIN
					RAISERROR('Missing value', 16, 1);
                END;
         END;
BEGIN TRANSACTION;
	UPDATE Accounts
		SET Balance-=@moneyAmount
		WHERE Id = @accountId;
	IF(@@ROWCOUNT <> 1)
		BEGIN
			RAISERROR('Account does not  exists', 16, 1);
			ROLLBACK;
         END;
	ELSE
		BEGIN
		DECLARE @nessesaryBallance DECIMAL(15,4) = 0;
		DECLARE @actualBallance DECIMAL(15,4) = 
			   (SELECT Balance
				FROM Accounts
				WHERE Id = @accountId)
			IF(@nessesaryBallance >= @actualBallance)
			BEGIN
				ROLLBACK;
				RAISERROR('Not Enough Ballance', 16, 1);
			END;
		END;
	COMMIT;
END;

/*****************************************************
Problem 18. Money Transfer
******************************************************/

GO
CREATE PROCEDURE usp_TransferMoney
(
                 @senderId   INT,
                 @receiverId INT,
                 @amount     MONEY
)
AS
     BEGIN
         IF(@amount < 0)
             BEGIN
                 RAISERROR('Cannot transfer negative amount', 16, 1);
         END;
             ELSE
             BEGIN
                 IF(@senderId IS NULL
                    OR @receiverId IS NULL
                    OR @amount IS NULL)
                     BEGIN
                         RAISERROR('Missing value', 16, 1);
                 END;
         END;

-- Withdraw from the sender
         BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance-=@amount
         WHERE Id = @senderId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Sender''s account doesn''t exists', 16, 1);
         END;

-- Check sender's current balance
         IF(0 >
           (
               SELECT Balance
               FROM Accounts
               WHERE ID = @senderId
           ))
             BEGIN
                 ROLLBACK;
                 RAISERROR('Not enough funds', 16, 1);
         END;

-- Add money to the receiver
         UPDATE Accounts
           SET
               Balance+=@amount
         WHERE ID = @receiverId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Receiver''s account doesn''t exists', 16, 1);
         END;
         COMMIT;
     END;

/*****************************************************
Part 2. Queries for Diablo Database
Problem 19. Trigger
******************************************************/



/*****************************************************
Problem 20. *Massive Shopping
******************************************************/



/*****************************************************
Part 3. Queries for SoftUni Database
Problem 21. Employees with Three Projects
******************************************************/



/*****************************************************
Problem 22. Delete Employees
******************************************************/