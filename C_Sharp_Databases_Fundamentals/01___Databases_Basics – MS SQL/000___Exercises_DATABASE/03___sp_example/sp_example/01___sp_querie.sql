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
