

-- this simple table and SP is just example.It shows 2 diff. approaches how to use try catch block and transaction , to raise error or just to handle the error in variable(as it is in my case because 
--	of demonstration purposes only).But offcourse it can be handled from another stored procedures.
-- print some numbers during the code is purposelly done because i have simulated  UN commited tranasction and this is the best way to catch the error




USE BankTestDb

CREATE TABLE Accounts(
AccountId INT IDENTITY not null,
[Name] NVARCHAR(100) not null,
Salary DECIMAL(15,2)
)
ALTER TABLE Accounts 
ADD CONSTRAINT pk_Accounts PRIMARY KEY CLUSTERED (AccountId)

SELECT * FROM Accounts

INSERT INTO Accounts
VALUES
('petko', 300.00),
('ivan', 400.00)



GO
CREATE OR ALTER PROC sp_transfer_money
@receiver_id NVARCHAR(100),
@sender_account_id INT,
@sender_amount DECIMAL(15,2) 
AS
BEGIN 
  -- declare variables
  -- Constants
  DECLARE @C_RETURN_CODE_NO_ERRORS                          INT;             SET @C_RETURN_CODE_NO_ERRORS = 0;
  DECLARE @C_RETURN_CODE_ERROR                              INT;             SET @C_RETURN_CODE_ERROR = 1;
  DECLARE @C_RETURN_CODE_UNEXPECTED_ERROR                   INT;             SET @C_RETURN_CODE_UNEXPECTED_ERROR = 9;

  -- Variables
  DECLARE @v_return_code									INT;             SET @v_return_code = @c_return_code_UNEXPECTED_ERROR;
  DECLARE @v_local_transaction_active                       BIT;             SET @v_local_transaction_active = 0;

  DECLARE @v_receiver_id                                    INT;             SET @v_receiver_id = null;
  DECLARE @v_sender_id                                      INT;             SET @v_sender_id = null;
  DECLARE @v_sender_amount_available                        DECIMAL(15,2)    SET @v_sender_amount_available = null;
  DECLARE @v_error_message			                        VARCHAR(MAX)	 SET @v_error_message = null;			
		
  
BEGIN TRY 

	SET NOCOUNT ON;
	SET @v_local_transaction_active = 1;

	BEGIN TRANSACTION
	 print 'hello'
	 -- can be done in both ways
	 --set @v_receiver_id = (select AccountId from Accounts a where a.AccountId = @receiver_id);
	 --set @v_sender_id = (select AccountId from Accounts where AccountId = @sender_account_id);
	 --set @v_sender_amount_available = (select Salary from Accounts where AccountId = @sender_account_id);

	 SELECT @v_receiver_id = AccountId from Accounts a where a.AccountId = @receiver_id;
	 SELECT @v_sender_id = AccountId from Accounts where AccountId = @sender_account_id;
	 SELECT @v_sender_amount_available = Salary from Accounts where AccountId = @sender_account_id;
	 
	 print '1'
	 IF(ISNULL(@v_receiver_id, '') = '')
	 BEGIN
	 
	 --RAISERROR('Receiver is missing in the table Accounts !!!', 16, 1)
	 set @v_error_message = 'Receiver is missing in the table Accounts !!!'
	 GOTO ERRORS_FOUND;
	 END

	 IF(ISNULL(@v_sender_id, '') = '')
	 BEGIN
	 
	 --RAISERROR('Sender is missing in the table Accounts !!!', 16, 1)
	 set @v_error_message = 'Sender is missing in the table Accounts !!!'
	 goto ERRORS_FOUND;
	 END

	 IF(@v_sender_amount_available < @sender_amount)
	 BEGIN
	 
	 --RAISERROR('You dont have enough money in your account !!!', 16, 1)
	 set @v_error_message = 'You dont have enough money in your account !!!'
	 goto ERRORS_FOUND;
	 END

	 ELSE
	 print '2'
	 BEGIN 
		
		UPDATE Accounts
		SET @v_sender_amount_available = Salary -= @sender_amount
		WHERE AccountId = @v_sender_id

		UPDATE Accounts 
		SET Salary += @sender_amount
		WHERE AccountId = @v_receiver_id
		print '3'
		GOTO CONTROLLED_END_OF_PROGRAM;
	 END
	
	CONTROLLED_END_OF_PROGRAM:
	print '4'
    IF @v_return_code = @c_return_code_UNEXPECTED_ERROR BEGIN
      SET @v_return_code = @c_return_code_NO_ERRORS;  -- No errors
      GOTO FINAL_END_OF_PROGRAM;
    END;


	ERRORS_FOUND:
    SET @v_return_code = @c_return_code_ERROR; -- Error Found

	FINAL_END_OF_PROGRAM:
	print '5'

END TRY 

BEGIN CATCH 
print'5.1'
	SET @v_return_code = @c_return_code_UNEXPECTED_ERROR;

  SELECT ERROR_NUMBER() as errorNumber
		,ERROR_SEVERITY() as errorSeverity
		,ERROR_STATE() as errorState
		,ERROR_PROCEDURE() as errorProcedure
		,ERROR_LINE() as errorLine
		,ERROR_MESSAGE() as errorMessage
		
END CATCH
	print '6'
	IF @v_local_transaction_active = 1 
	BEGIN
	print '6.1'

		IF @v_return_code = @c_return_code_NO_ERRORS 
		BEGIN
		print 'commit'
			COMMIT TRANSACTION;
		END 
		ELSE IF XACT_STATE() <> 0 
		BEGIN
			print @v_error_message
			ROLLBACK  TRANSACTION;

		END;
	END;
	RETURN @v_return_code;
END
GO

EXEC sp_transfer_money @receiver_id  = 11,@sender_account_id = 2, @sender_amount = 2000
select * from Accounts

GO

-- --------------------------------------------------------------------------------------------------------------------------------------


-- CREATE PROCEDURE WITH TRY CATCH BLOCK AND TRANSACTION

CREATE OR ALTER PROCEDURE f_MyCustomConcatProcedure 
(
 @firstname VARCHAR(50),
 @lastname VARCHAR(50),
 @ConcatName VARCHAR(100) OUTPUT
)
AS
BEGIN
  -- DECLARATION 
  -- ===========
  DECLARE @first VARCHAR(MAX)      --SET @first = (SELECT FirstName 
													--FROM Employees e
												  -- WHERE e.FirstName = @firstname 
													   --  AND e.LastName = @lastname)
  DECLARE @last VARCHAR(MAX)        --SET @last = (SELECT LastName 
												  -- FROM Employees e
												 -- WHERE e.FirstName = @firstname 
													--AND e.LastName = @lastname)

  -- INITIALIZATION
  -- ==============
  BEGIN TRY
  BEGIN TRANSACTION
	-- here is what actually store procedure does 
	-- in this case it just simple concat function of two names which comes from input params, and are selected from the Employees table
	-- example one
	--SET @ConcatName = @first + ' ' + @last;
	-- example two
	SET @ConcatName = @firstname + ' ' + @lastname;

	--custom set return codes just for test purposes
	--IF @ConcatName = @ConcatName BEGIN
	--RETURN 18
	--END
	--ELSE 
	--RETURN 23
    -- all end up here  and from this point further  whatever exception is thrown will be catched in the CATCH block and we will ROLLBACK the transaction
	-- or if we have another condition we will also ROLLBACK the transaction
	-- in this scenario if the name is longer or equal 50 will rollback the transaction and it will raiserror that "this name is too long" 
	-- if i UNcomment the other case and comment this one it will change the return code from it's default value (0) to 18 (just a random number i picked) 
  END TRY
  BEGIN CATCH 
    PRINT 'Error message In CATCH Block';
	THROW;
  END CATCH 
  IF  DATALENGTH(@ConcatName) < 50  
    BEGIN
	  COMMIT TRANSACTION
    END 
  ELSE IF XACT_STATE() <> 0 
    BEGIN 
      RAISERROR('this name is too long',16,1)
      ROLLBACK TRANSACTION
    END
END

-- CHECK THE RESULT FROM STORED PROCEDURE

DECLARE @FullName NVARCHAR(100)
EXEC f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT
SELECT @FullName AS fullname

-- this is very important return code which in this case  we assign it to variable @returnCode - 0 means no error
-- but because i change it in SP it will be 18 - but off course it must be UN comment!!!
go
DECLARE @returnCode VARCHAR(MAX)
Declare @fullName VARCHAR(MAX)
EXEC @returnCode = dbo.f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @fullName OUTPUT
SELECT @returnCode AS returnCode
SELECT @fullName AS fullName


-- -------------------------------------------------------------------------------------------------------------------------

go
create or alter proc sp_test_proc
(@FirstNumber int,
@LastNumber int,
@Result int out)
AS
begin
	begin try
	Set @Result = @FirstNumber / @LastNumber
	end try
	begin catch
		select ERROR_NUMBER() as errorNumber
		,ERROR_SEVERITY() as errorSeverity
		,ERROR_STATE() as errorState
		,ERROR_PROCEDURE() as errorProcedure
		,ERROR_LINE() as errorLine
		,ERROR_MESSAGE() as errorMessage
	end Catch
end
go
declare @outputResult int
exec sp_test_proc 4,0,@outputResult
select @outputResult


