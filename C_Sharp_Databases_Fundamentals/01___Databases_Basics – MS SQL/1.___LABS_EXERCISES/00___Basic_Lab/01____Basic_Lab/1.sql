CREATE DATABASE Bank
GO

USE Bank
GO

CREATE TABLE Clients (
	Id INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
)
GO

CREATE TABLE AccountTypes (
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
)
GO	

CREATE TABLE Accounts (
	Id INT PRIMARY KEY,
	AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(Id) NOT NULL,
	Balance DECIMAL (15,2) DEFAULT (0),
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL, 
)
GO

INSERT INTO Clients (Id, FirstName, LastName) 
VALUES
(1, 'Gosho', 'Ivanov'),
(2, 'Pesho', 'Petrov'),
(3, 'Ivan', 'Iliev'),
(4, 'Merry', 'Ivanova')
GO
 
INSERT INTO AccountTypes(Id, [Name])
VALUES
(1, 'Checking'),
(2, 'Savings'),
(3, 'Savings'),
(4, 'Checking')
GO

INSERT INTO Accounts (Id, AccountTypeId, Balance, ClientId) 
VALUES
--(2, 2, 200, 2),
--(3, 1, 550, 3),
--(4, 1, 1000.23, 4),
--(5, 1, 123.55, 4)
(6, 1, 1023.55, 4)
GO

CREATE FUNCTION f_CalculateTotalBalance (@ClientID INT)
RETURNS DECIMAL(15, 2)
BEGIN
	DECLARE @result AS DECIMAL(15, 2) = (
	  SELECT SUM(Balance) 
	  FROM Accounts WHERE ClientId = @ClientID
	)	
  RETURN @result
END
GO

SELECT dbo.f_CalculateTotalBalance(4) 
    AS [Total Balance]
GO

CREATE PROCEDURE p_AddAccount @Id INT, 
		@ClientId INT, @AccountTypeId INT AS
INSERT INTO Accounts (Id, ClientId, AccountTypeId) 
VALUES (@Id, @ClientId, @AccountTypeId)
GO

p_AddAccount 7,2,1
GO
p_AddAccount 8,1,1
GO 

CREATE PROC p_Deposit (@AccountId INT, @Amount DECIMAL(15, 2)) AS
UPDATE Accounts
SET Balance += @Amount
WHERE Id = @AccountId
GO

p_Deposit 2,100
GO

CREATE PROCEDURE p_Withdraw @AccountId INT, @Amount DECIMAL(15, 2) AS
BEGIN
	DECLARE @OldBalance DECIMAL(15, 2)
	SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
	IF (@OldBalance - @Amount >= 0)
	BEGIN
		UPDATE Accounts
		SET Balance -= @Amount
		WHERE Id = @AccountId
	END
	ELSE
	BEGIN
		RAISERROR('Insufficient funds', 10, 1)
	END
END
GO

p_Withdraw 2, 100
GO

SELECT Balance [AS Balance After WithDraw]
	FROM Accounts 
	WHERE Id = 2
GO 

CREATE TABLE Transactions (
	Id INT PRIMARY KEY IDENTITY,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldBalance DECIMAL(15, 2) NOT NULL,
	NewBalance DECIMAL(15, 2) NOT NULL,
	Amount AS NewBalance - OldBalance,
	[DateTime] DATETIME2
)
GO

CREATE TRIGGER tr_Transaction ON Accounts
AFTER UPDATE
AS
	INSERT INTO Transactions (AccountId, OldBalance, NewBalance, [DateTime])
	SELECT inserted.Id, deleted.Balance, inserted.Balance, GETDATE() 
	FROM inserted
	JOIN deleted ON inserted.Id = deleted.Id
GO
p_Deposit 1, 25.00
GO

p_Deposit 1, 40.00
GO

p_Withdraw 2, 200.00
GO

p_Deposit 4, 180.00
GO
SELECT * FROM Transactions