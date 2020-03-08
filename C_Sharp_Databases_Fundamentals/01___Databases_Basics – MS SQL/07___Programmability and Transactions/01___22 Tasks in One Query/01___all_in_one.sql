  
/*****************************************************
--Section I. Functions and Procedures
--Part 1. Queries for SoftUni Database
Problem 1. Employees with Salary Above 35000
******************************************************/


GO
CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT e.FirstName, e.LastName 
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
	AS 
  (
	SELECT a.AccountHolderId, 
         SUM(a.Balance) AS TotalBallance
	  FROM Accounts AS a
GROUP BY a.AccountHolderId
  )

	SELECT ah.FirstName,
         ah.LastName
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
		--select * from inserted
		--select * from deleted
		DECLARE @accountID INT = (SELECT Id FROM inserted)
		DECLARE @oldSum DECIMAL(15,4) = (SELECT Balance FROM deleted where id = @accountID)
		DECLARE @newSum DECIMAL(15,4) = (SELECT Balance FROM inserted where id = @accountID)

		INSERT INTO Logs 
		VALUES
		(@accountID, @oldSum,@newSum)
		
END

UPDATE Accounts 
   SET Balance = 6666 WHERE Id = 2
SELECT * FROM Accounts
SELECT * FROM Logs
SELECT * FROM AccountHolders


/*****************************************************
Problem 15. Create Table Emails
******************************************************/
go
create table notification_emails(
	Id INT IDENTITY NOT NULL, 
	Recipient INT NOT NULL, 
	[Subject] VARCHAR(64), 
	Body VARCHAR(MAX)
)
ALTER TABLE notification_emails
ADD CONSTRAINT PK_notification_email PRIMARY KEY(Id)
-- RECIPIENT could be foreign key but for the purpose of this task it does not matter 
-- in this way is much easier for reading
GO
create OR ALTER trigger tr_email_notification
on Logs
for insert
as
begin
		declare @Recipient_Id  int     set @Recipient_Id = (select i.AccountId from inserted i )
		declare @Subject varchar(64)   set @Subject = (select concat('Balance change for account: ',(@Recipient_Id)))
		declare @old_sum decimal(15,4) set @old_sum = (select i.OldSum from inserted i)
		declare @new_sum decimal(15,4) set @new_sum = (select i.NewSum from inserted i)

		declare @body varchar(max)     set @body = (select CONCAT('On ', GETDATE(), ' your balance was changed from ', @old_sum, ' to ', @new_sum, '.'))
		insert into notification_emails 
		values 
    (@Recipient_Id,@Subject, @body)

end

INSERT INTO Logs(AccountId,OldSum,NewSum)
VALUES
(6,666,999)
SELECT * FROM notification_emails
SELECT * FROM Logs


-- --------------------------------------------------------------------------


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
			ROLLBACK
			RAISERROR('Negative Deposit Amount, Enter positive value', 16, 1);
			RETURN
		END;
	-- we could check if the amount is <=  0 or in separate if with different message , but because of the purpose of the task  we won't do it, and 
	-- i will just add another if in the transaction because there is no need to make an update without actual change in the table 
	--IF(@moneyAmount = 0)
	--	BEGIN
	--		RAISERROR('Deposit amount is Zero, Please enter amount bigger than 0 !', 16, 1);
	--	END;
	ELSE
		BEGIN
			--IF(ISNULL(@accountId, 0) = 0 or ISNULL(@moneyAmount, 0) = 0)
			IF(@accountId IS NULL  OR @moneyAmount IS NULL)
				BEGIN
					ROLLBACK
					RAISERROR('Please enter a value', 16, 1);
					RETURN
				END;
		END;
         
	BEGIN TRANSACTION;
	if(@moneyAmount > 0)
	BEGIN
		UPDATE Accounts 
			SET Balance+=@moneyAmount
		    WHERE Id = @accountId;
				-- if we have different amount of affected rows which in this case is 1 we raiserror and rollback  the transaction
				IF(@@ROWCOUNT <> 1)
				BEGIN
					ROLLBACK;
					RAISERROR('Account doesn''t exists', 16, 1);
				END;	
	END
	COMMIT
END;

/*****************************************************
Problem 17. Withdraw Money
******************************************************/

GO

CREATE or alter PROCEDURE usp_WithdrawMoney(
                 @accountId   INT,
                 @moneyAmount DECIMAL(15,4))
AS
BEGIN

  DECLARE @v_sql_error_number                               INT;
  DECLARE @v_sql_error_severity                             INT;
  DECLARE @v_sql_error_state                                INT;
  DECLARE @v_sql_error_procedure                            NVARCHAR(126);
  DECLARE @v_sql_error_line                                 INT;
  DECLARE @v_sql_error_message                              NVARCHAR(2048);

BEGIN TRY 
	IF(@moneyAmount < 0)
		BEGIN;
			--RAISERROR('Negative Amount,Please Enter positive value', 16, 1);
      THROW 66666, 'Negative Amount,Please Enter positive value', 1;
		END
	ELSE
		BEGIN
			IF(@accountId IS NULL OR @moneyAmount IS NULL)
				BEGIN
					RAISERROR('Please enter a value', 16, 1);
        END;
    END;
		 DECLARE @actualBallance DECIMAL(15,4) = (SELECT Balance FROM Accounts WHERE Id = @accountId)
     
BEGIN TRANSACTION;
  
  	-- if we dont have enough money we won't make the transaction at all, so that's why i check only if i my ballance is >= of @moneyAmount
  	IF(@actualBallance >= @moneyAmount)
  	BEGIN
  		UPDATE Accounts
  		   SET Balance -= @moneyAmount
  		 WHERE Id = @accountId;
       COMMIT TRANSACTION;
  		IF XACT_STATE() <> 0
  			BEGIN
  				ROLLBACK;
  				RAISERROR('Account does not  exists', 16, 1);
  				RETURN 1
  			END;
  	END
END TRY
BEGIN CATCH 

  SELECT @v_sql_error_number = ERROR_NUMBER(), 
      @v_sql_error_severity = ERROR_SEVERITY(), 
      @v_sql_error_state = ERROR_STATE(), 
      @v_sql_error_procedure = ERROR_PROCEDURE(), 
      @v_sql_error_line = ERROR_LINE(), 
      @v_sql_error_message = ERROR_MESSAGE();

      print @v_sql_error_number 
      print @v_sql_error_severity   
      print @v_sql_error_state
      print @v_sql_error_line
      print @v_sql_error_message

END CATCH
END;

exec usp_WithdrawMoney 1, -23
select * from Accounts 
/*****************************************************
Problem 18. Money Transfer
******************************************************/
use Bank
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
                 IF(@senderId	   IS NULL
                 OR @receiverId    IS NULL
                 OR @amount        IS NULL)
                     BEGIN
                         RAISERROR('Missing value', 16, 1);
					 END;
		     END;
-- Withdraw from the sender
		 DECLARE @actualBallance DECIMAL(15,4) = (SELECT Balance FROM Accounts WHERE Id = @senderId)
         
		 BEGIN TRANSACTION;
		 IF(@amount > @actualBallance)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Not enough funds', 16, 1)
				 RETURN
			 END

			UPDATE Accounts
			  SET Balance-=@amount
			WHERE Id = @senderId;
			IF(@@ROWCOUNT < 1)
			    BEGIN
			        ROLLBACK;
			        RAISERROR('Sender''s account doesn''t exists', 16, 1);
					RETURN
				END;
-- Add money to the receiver
		 IF(@amount > 0)
		 BEGIN
			 UPDATE Accounts
			    SET Balance+=@amount
			  WHERE ID = @receiverId;
			 IF(@@ROWCOUNT < 1)
			     BEGIN
			         ROLLBACK;
			         RAISERROR('Receiver''s account doesn''t exists', 16, 1);
				 END
		 END	 
		COMMIT
     END

/*****************************************************
Part 2. Queries for Diablo Database
Problem 19. Trigger
******************************************************/
-- SUB TASK 1

go
select * from Users
select * from Games
select * from UsersGames
select * from Items
select * 
  from Users u
  join UsersGames ug on ug.UserId = u.Id
  where ug.id = 2 -- linda williams level 30 

 
select * 
from UserGameItems ugi
join UsersGames ug on ug.Id = ugi.UserGameId
join Users u on u.Id = ug.UserId 
join Items i on i.Id = ugi.ItemId
where ug.Id = 2

delete from UserGameItems
insert into UserGameItems(ItemId, UserGameId)
values
(5,2)

select * from UserGameItems where UserGameId = 2 and ItemId = 4 -- itemId = 6 is level 78  itemId 4 = 20 
-- so with the first item won't be allowed , with second will be inserted
-- to be easier i have added  print message to show us the result

go
create or alter trigger tr_restrict 
on UserGameItems 
instead of insert
as
begin
	declare @item_id int set @item_id = (select top(1) i.ItemId from inserted i )
	declare @user_games_id int set @user_games_id = (select top(1) i.UserGameId from inserted i )
	
	declare @item_level int set @item_level = (select top(1) i.MinLevel from Items i         where i.Id  = @item_id)
	declare @user_level int set @user_level = (select top (1) ug.Level  from UsersGames ug   where ug.Id  = @user_games_id)

	if(@user_level >= @item_level)
	begin
		insert into UserGameItems
		values(@item_id,@user_games_id)
		print 'You successfully inserted one row in the table UserGameItems'
	end
	else
	begin
		Print 'Sorry but values your are trying to insert are not allowed'
	end
end

-- SUB TASK 1 ------------------------------------------------------------------------------------------------------


select * 
  from UsersGames ug
  join Games g on g.Id = ug.GameId
  join Users u on u.Id = ug.UserId
 where g.Name = 'Bali' -- if we i dont put a bracket on the second condition will get wrong result !!!!
   and (u.Username like 'baleremuda'      or
		    u.Username like 'loosenoise'      or
		    u.Username like 'inguinalself'    or
		    u.Username like 'buildingdeltoid' or
		    u.Username like 'monoxidecos') 

	
	-- first approach
	declare @game_id int  set @game_id = (select g.Id from Games g where g.Name = 'Bali')
update UsersGames
   set  Cash += 50000
 where UserId in (select u.Id from Users u where u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
   and GameId = @game_id

   -- second approach
	update ug
	 set  Cash += 50000
	 from UsersGames ug
	 join Users u
	 on u.Id = ug.UserId
	 join Games g
	 on g.Id = ug.GameId
  where u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
    and g.Name = 'Bali'


	--  third approach but WRONG !!! it will work but it is bad practice !!!
	DECLARE @v_user_id int
	DECLARE @v_game_id int
	
	  SELECT @v_game_id = g.Id 
      FROM Games g 
     WHERE g.[Name] = 'Bali'

	DECLARE cur CURSOR FOR
	 SELECT u.Id 
     FROM Users u 
    WHERE u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
	
	OPEN cur
	FETCH NEXT FROM cur INTO @v_user_id 

	  WHILE @@FETCH_STATUS <> -1 
    BEGIN
	    UPDATE UsersGames
	   	  SET  Cash += 50000
	     WHERE UserId = @v_user_id
	   	  AND GameId = @v_game_id
    
	    FETCH NEXT FROM cur INTO @v_user_id 
	  END
	CLOSE cur
	DEALLOCATE cur

  select * from UsersGames

	-- fourth approach  - that is how the cursor must be done - always by PRIMARY KEY
	DECLARE @v_usergames_id  int
	
	DECLARE cur cursor for
   select ug.Id
	 from UsersGames ug
	 join Users u on u.Id = ug.UserId
	 join Games g on g.Id = ug.GameId
    where u.Username in ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
    and g.Name = 'Bali'
	
	OPEN cur
	FETCH NEXT FROM cur INTO @v_usergames_id 

	WHILE @@FETCH_STATUS <> -1 BEGIN
	 update UsersGames
		set  Cash += 50000
	  where Id = @v_usergames_id
		
	  FETCH NEXT FROM cur INTO @v_usergames_id 
	END
	close cur
	deallocate cur

-- SUB TASK 3 -----------------------------------------------------------------------------------------------------

select * from UsersGames where GameId = 212


declare @counter int	 set @counter = 251
declare @counter_max int set @counter_max = 299

while(@counter <= @counter_max)
	begin
		
		exec sp_item_to_buy 12, @counter, 212
		exec sp_item_to_buy 22, @counter, 212
		exec sp_item_to_buy 37, @counter, 212
		exec sp_item_to_buy 52, @counter, 212
		exec sp_item_to_buy 61, @counter, 212


		set @counter += 1
	end
go
declare @counter int	 set @counter = 501
declare @counter_max int set @counter_max = 539
while(@counter <= @counter_max)
	begin
		
		exec sp_item_to_buy 12, @counter, 212
		exec sp_item_to_buy 22, @counter, 212
		exec sp_item_to_buy 37, @counter, 212
		exec sp_item_to_buy 52, @counter, 212
		exec sp_item_to_buy 61, @counter, 212


		set @counter += 1
	end

go
create or alter proc sp_item_to_buy
(
@user_id int, 
@item_id int,
@game_id int 
)
as
begin

begin transaction
	-- first we check the input  params 
	declare @user_exist int  set @user_exist = (select u.Id from Users u where u.Id = @user_id)
	declare @item_exist int  set @item_exist = (select i.Id from Items i where i.Id = @item_id)
	declare @game_exist int  set @game_exist = (select g.Id from Games g where g.Id = @game_id)
	
	if(ISNULL(@user_exist, 0) = 0 or isnull(@item_exist, 0) = 0 or isnull(@game_exist, 0) = 0)
		begin
			rollback
			raiserror('Invalid input parameters!', 16, 1)
			return 
		end
	
	declare @cash_user      decimal(16,2)       set @cash_user = (select ug.Cash from UsersGames ug where ug.UserId = @user_id and ug.GameId = @game_id)
	declare @price_for_item decimal(16,2)       set @price_for_item = (select i.Price from Items i where i.Id = @item_id)
	declare @user_game_id   decimal(16,2)       set @user_game_id = (select ug.Id from UsersGames ug where ug.UserId = @user_id and ug.GameId = @game_id)

	if(@cash_user < @price_for_item)
	begin
		rollback
		raiserror('Not enough money!', 16, 2)
		return 
	end
	else
		begin
			update UsersGames
			   set Cash -= @price_for_item
			 where GameId = @game_id
			   and UserId = @user_id
			   
			insert into UserGameItems
			values
			(@item_id, @user_game_id) 
		end
commit
end

-- SUB TASK 4 -----------------------------------------------------------------------------------------------------

select u.Username,g.[Name],ug.Cash,i.[Name] 
  from Users u
  join UsersGames ug         on ug.UserId =u.Id
  join Games g               on g.Id = ug.GameId
  join UserGameItems ugi     on ugi.UserGameId = ug.Id
  join Items i               on i.Id = ugi.ItemId
  where g.[Name] = 'Bali'
  order by u.Username, i.[Name] 


/*****************************************************
Problem 20. *Massive Shopping
******************************************************/
-- stamat -id 9
-- safflower - id - 87
select * from Users u  where u.username = 'stamat'
select * from Games g  where g.Name = 'safflower'
select * from items i  where (i.MinLevel between 11 and 12)
select * from UserGameItems
go
 declare @user_game_id int set @user_game_id = (select ug.Id 
                                                  from UsersGames ug  
												                         where ug.UserId = 9 
											                             and ug.GameId = 87)

 declare @user_stamat_money decimal (16,2) set @user_stamat_money = (select ug.Cash 
																	                                     from UsersGames ug 
																	                                    where ug.Id = @user_game_id)

 declare @items_total_price  decimal(16,2) set @items_total_price =  (select sum(i.Price) 
																		                                    from Items i 
																	                                     where (i.MinLevel between 11 and 12))



 if(@user_stamat_money >= @items_total_price)
	begin
		begin transaction
		update UsersGames
		   set Cash -= @items_total_price
		 where Id = @user_game_id

		insert into UserGameItems(ItemId, UserGameId)
		select i.Id, @user_game_id 
		  from Items i 
		 where (i.MinLevel between 11 and 12)
		commit
	end


 set @items_total_price =  (select sum(i.Price) 
							                from Items i 
						                 where (i.MinLevel between 19 and 21))

 if(@user_stamat_money >= @items_total_price)
	begin
		begin transaction
		update UsersGames
		set Cash -= @items_total_price
		where Id = @user_game_id

		insert into UserGameItems(ItemId, UserGameId)
		select i.Id, @user_game_id 
		  from Items i 
		 where (i.MinLevel between 19 and 21)
		 commit
	end


	select i.Name 
  from Users u
  join UsersGames ug on ug.UserId = u.Id
  join Games g on g.Id = ug.GameId
  join UserGameItems ugi on ugi.UserGameId = ug.Id
  join Items i on i.Id = ugi.ItemId
  where u.Username = 'Stamat' and g.Name = 'Safflower'
  order by i.Name


select i.id 
  from Items i 
  where (i.MinLevel between 11 and 12) or (i.MinLevel between 19 and 21)


/*****************************************************
Part 3. Queries for SoftUni Database
Problem 21. Employees with Three Projects
******************************************************/
use SoftUni
select * from Employees 
select * from Projects 
select * from EmployeesProjects

select ep.EmployeeID, count(ep.ProjectID)  count_of_projects
  from EmployeesProjects ep
  group by ep.EmployeeID
  having count(ep.ProjectID) < 3


select *
 from Employees e
 join EmployeesProjects ep on ep.EmployeeID = e.EmployeeID
 join Projects p on p.ProjectID = ep.ProjectIDemployee_exist
   


create proc usp_AssignProject
(
@emloyeeId int, 
@projectID int 
)
as
begin
begin transaction
	declare @employee_exist int		set @employee_exist  = (select e.EmployeeID 
														   from Employees e 
														  where e.EmployeeID = @emloyeeId)

	declare @project_exist int		set @project_exist  = (select p.ProjectID 
														   from Projects p 
														  where p.ProjectID = @projectID)

	declare @count_of_projects int  set @count_of_projects = (select count(ep.ProjectID) 
																from EmployeesProjects ep 
															   where ep.EmployeeID = @emloyeeId)


	if(ISNULL(@employee_exist, 0) = 0 or ISNULL(@project_exist, 0) = 0)
		begin
			rollback
			raiserror('Invalid Input params!', 16, 1)
			return
		end
	if(@count_of_projects >= 3)
		begin
			rollback
			raiserror('The employee has too many projects!', 16, 1)
			return
		end
	else
		begin
			insert into EmployeesProjects(EmployeeID, ProjectID)
			values
			(@emloyeeId, @projectID)
		end
	commit
end

exec usp_AssignProject 219, 1

/*****************************************************
Problem 22. Delete Employees
******************************************************/
go

create table Deleted_Employees
(
EmployeeId int primary key,
FirstName varchar(50),
LastName varchar(50),
MiddleName varchar(50),
JobTitle varchar(50),
DepartmentId int, 
Salary decimal (16,2)
)
go
create trigger tr_deleted_employees on Employees for delete 
as
begin

	insert into Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	select 
		   d.FirstName, 
		   d.LastName, 
		   d.MiddleName, 
		   d.JobTitle, 
		   d.DepartmentID, 
		   d.Salary 
	  from deleted d

	-- thit is another syntax but it wont work in this case 
	--insert into Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	--select 
	--	   d.FirstName, 
	--	   d.LastName, 
	--	   d.MiddleName, 
	--	   d.JobTitle, 
	--	   d.DepartmentID, 
	--	   d.Salary 
	--  into Deleted_Employees_temp
	--  from deleted d
end 


	  