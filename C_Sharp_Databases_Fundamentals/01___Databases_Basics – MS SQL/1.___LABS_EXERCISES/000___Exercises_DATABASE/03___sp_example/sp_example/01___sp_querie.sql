-- CREATE PROCEDURE WITH TRY CATCH BLOCK AND TRANSACTION

CREATE OR ALTER PROCEDURE f_MyCustomConcatProcedure 
(
 @firstname VARCHAR(50),
 @lastname VARCHAR(50),
 @ConcatName VARCHAR(50) OUTPUT
)
AS
BEGIN
  -- DECLARATION 
  -- ===========
  DECLARE @first VARCHAR(MAX)       SET @first = (SELECT FirstName 
													FROM Employees e
												   WHERE e.FirstName = @firstname 
													     AND e.LastName = @lastname)
  DECLARE @last VARCHAR(MAX)        SET @last = (SELECT LastName 
												   FROM Employees e
												  WHERE e.FirstName = @firstname 
													AND e.LastName = @lastname)

  -- INITIALIZATION
  -- ==============
  BEGIN TRY
  BEGIN TRANSACTION
	-- here is what actually store procedure does 
	-- in this case it just simple concat function of two names which comes from input params, and are selected from the Employees table
	SET @ConcatName = @first + ' ' + @last;
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

DECLARE @FullName NVARCHAR(max)
EXEC f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT
SELECT @FullName AS fullname

-- this is very important return code which in this case  we assign it to variable @TESTvar - 0 means no error
-- but because i change it in SP it will be 18.

DECLARE @TESTvar VARCHAR(MAX)
EXEC @TESTvar = dbo.f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @TESTvar OUTPUT
SELECT @TESTvar AS finalPrint
