
USE SoftUni
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																			STORED PROCEDURES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
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
  DECLARE @first varchar(max)       SET @first = (SELECT FirstName 
													  FROM Employees e
													 WHERE e.FirstName = @firstname 
													   AND e.LastName = @lastname)
  DECLARE @last varchar(max)        SET @last = (SELECT LastName 
												     FROM Employees e
													WHERE e.FirstName = @firstname 
													  AND e.LastName = @lastname)

  -- INITIALIZATION
  -- ==============
  BEGIN TRY
  BEGIN TRANSACTION
	-- here is what actually store procedure does 
	-- in this case it just simple concat function of two names which comes from input params
	SET @ConcatName = @first + ' ' + @last;
	--custom set return codes just for test purposes
	--IF @ConcatName = @ConcatName BEGIN
	--RETURN 18
	--END
	--ELSE 
	--RETURN 23
    -- all end up here  and from this point further  whatever exception is thrown will be catched in the CATCH block and we will ROLLBACK the transaction
	-- or if we have another condition we will also ROLLBACK the transaction
	-- in this scenario if the name is longer than 50 will rollback the transaction and it will raiserror that "this name is too long" 
	-- if i UNcomment the other case and comment this one  it will change the return code from it;s default value (0) to 18 (just a random number i picked) 
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
	
GO
-- CHECK THE RESULT FROM STORED PROCEDURE

DECLARE @FullName NVARCHAR(max)
EXEC f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT
SELECT @FullName AS fullname

-- this is very important return code which in this case  we assign it to variable @TESTvar - 0 means no error
-- but because i change it in SP it will be 18.

DECLARE @TESTvar VARCHAR(MAX)
EXEC @TESTvar = dbo.f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @TESTvar OUTPUT
SELECT @TESTvar AS finalPrint

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- CREATE PROCEDURE WITH TRY CATCH BLOCK AND TRANSACTION
select * from EmployeesProjects
GO
 ALTER PROCEDURE dbo.udp_assign_employee_project
 (
   @employeeId INT ,
   @projectId INT
   ) 
AS
BEGIN
  DECLARE @max_employee_projects_count INT  SET @max_employee_projects_count = 8
  DECLARE @employee_projects_count     INT  SET @employee_projects_count = (SELECT COUNT(*) 
 										   FROM EmployeesProjects ep
 										   WHERE ep.EmployeeID = @employeeId)
  BEGIN TRY
  BEGIN TRANSACTION 
    INSERT INTO EmployeesProjects(EmployeeID,ProjectID)
 	  VALUES
      (@employeeId,@projectId)
	  PRINT 'Last Statement in the TRY block';

  END TRY
  BEGIN CATCH 
    PRINT 'In CATCH Block';
	THROW;
  END CATCH 
  IF @employee_projects_count < @max_employee_projects_count BEGIN
	  COMMIT TRANSACTION
  END ELSE IF XACT_STATE() <> 0 BEGIN 
	  RAISERROR('The employee has too many projects',16,1)
 	  ROLLBACK TRANSACTION
  END
END

 GO
 -- CHECK THE RESULT FROM STORED PROCEDURE
 BEGIN TRANSACTION
 EXEC udp_assign_employee_project 1,33
 SELECT * FROM EmployeesProjects ep where ep.EmployeeID = 1


 -- |||||||||||||||||||||||||||||||||||||||||||||||||        3        ||||||||||||||||||||||||||||||||||||||||||||||||| 

 -- CREATE A PROCEDURE WITHOUT PARAM
-- -------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE udp_GetemployerbyHiredDate
AS
BEGIN
	SELECT e.FirstName,
		   e.LastName, 
		   DATEDIFF(YEAR,HireDate,GETDATE()) Experience 
	  FROM Employees e
	 WHERE DATEDIFF(YEAR,HireDate,GETDATE()) > 18
  ORDER BY HireDate
END

EXEC DBO.udp_GetemployerbyHiredDate

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        4        ||||||||||||||||||||||||||||||||||||||||||||||||| 
GO
-- CREATE A PROCEDURE WITH PARAM

CREATE OR ALTER PROCEDURE udp_GetInfoWithExperienceInYears
(
  @years INT
)
AS
BEGIN
	DECLARE @COUNTER INT SET @COUNTER = 1
	SELECT e.FirstName,
		   e.LastName,
		   e.HireDate,
		   DATEDIFF(YEAR,HireDate,GETDATE()) Years 
	  FROM Employees e
	 WHERE DATEDIFF(YEAR,HireDate,GETDATE()) > @years
	    IF @COUNTER = 1 BEGIN
	RETURN 666
	   END
	  ELSE 
	 BEGIN
	RETURN 999
	   END
END

DECLARE @TEST INT 
EXEC @TEST = DBO.udp_GetInfoWithExperienceInYears 18
SELECT @TEST

exec dbo.udp_GetInfoWithExperienceInYears 18

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        5        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- sp without and WITH optional param
GO

CREATE OR ALTER PROCEDURE udp_add_numbers
  @first_number  INT,
  @second_number INT,
  @result		 INT OUTPUT	
AS
BEGIN
	SET @result = @first_number + @second_number
END	
 -- @result = @answer or just @answer on the param is the same 
DECLARE @answer INT
EXEC DBO.udp_add_numbers 10, 100, @result = @answer OUTPUT 
SELECT CONCAT('the result is ',@answer) 'Final Answer'

GO

-- -----------------------------------------------------------
-- basically it tells : Give me id,firstname, lastname and jobtitle from this table WHERE
-- parameter is NULL OR the firstname is equal to the value of the paramm
-- SO it will give me only these records which i entered in the params, if all params are empthy and missing, their default value is NULL because i set it
-- and will give me all the records in this table
go
CREATE or ALTER PROCEDURE spDoSearch
    @FirstName VARCHAR(25) = null,
    @LastName VARCHAR(25) = null,
    @JobTitle VARCHAR(25) = null
AS
    BEGIN
       SELECT e.EmployeeID, e.FirstName, e.LastName,e.JobTitle 
         FROM Employees e
        WHERE (@FirstName IS NULL OR (e.FirstName = @FirstName))
          AND (@LastName  IS NULL OR (e.LastName  = @LastName ))
          AND (@JobTitle  IS NULL OR (e.JobTitle  = @JobTitle ))
       OPTION (RECOMPILE) 
    END

EXEC spDoSearch 


















SELECT e.FirstName FROM Employees e GROUP BY e.FirstName HAVING COUNT(*) > 1

















-- |||||||||||||||||||||||||||||||||||||||||||||||||        6        ||||||||||||||||||||||||||||||||||||||||||||||||| 

GO
--  CREATE PROCEDURE WITH TRANSACTION BUT WITHOUT TRY CATCH BLOCK

CREATE OR ALTER PROCEDURE udp_assign_employee_project
 (
   @employeeId INT ,
   @projectId INT
   ) 
AS
BEGIN
  DECLARE @max_employee_projects_count INT  SET @max_employee_projects_count = 3
  DECLARE @employee_projects_count     INT  SET @employee_projects_count = (SELECT COUNT(*) 
										   FROM EmployeesProjects ep
										   WHERE ep.EmployeeID = @employeeId)
  BEGIN TRANSACTION 
   INSERT INTO EmployeesProjects(EmployeeID,ProjectID)
   VALUES
   (@employeeId,@projectId)
	IF @employee_projects_count <= @max_employee_projects_count BEGIN
	  COMMIT
	END
	ELSE
	 RAISERROR ('EMPLOYEE HAS TOO MANY PROJECTS',16,1)
	 ROLLBACK
END

 EXEC DBO.udp_assign_employee_project 1,8

 GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																			TRIGERS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- update trigger
GO

CREATE OR ALTER TRIGGER tr_townUpdate ON Towns FOR UPDATE
 AS
 BEGIN
	IF EXISTS(SELECT * FROM inserted WHERE Name IS NULL OR LEN(NAME) = 0) 
	BEGIN
		RAISERROR('NAME CANNOT BE NULL OR EMPTHY',16,1)
		ROLLBACK
		RETURN 
	END
 END

 UPDATE Towns
 SET NAME = '' WHERE TownID = 1

 GO
 -- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
 -- delete trigger 
 GO
 CREATE TABLE Accounts(
  username VARCHAR(10) NOT NULL PRIMARY KEY,
  [password] VARCHAR(20) NOT NULL,
  Active CHAR(1) NOT NULL DEFAULT 'Y' 
 )
 GO
 INSERT INTO Accounts
VALUES
('petko','petkov','y'),
('ivan','ivanov','y'),
('georgi','georgiev','y')
GO
SELECT * FROM Accounts 

GO
CREATE OR ALTER TRIGGER TR_DELETE ON Accounts INSTEAD OF DELETE 
AS 
BEGIN 
	UPDATE a
	SET a.Active = 'N'
	FROM Accounts a
	join deleted d ON d.username = a.username
	WHERE d.Active = 'Y'
END 

DELETE FROM Accounts WHERE username = 'ivan'
SELECT * FROM Accounts
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																			FUNCTIONS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 

CREATE OR ALTER FUNCTION f_MyCustomFuntion (@firstname VARCHAR(50),@lastname VARCHAR(50))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @ConcatName varchar(max)
	DECLARE @first varchar(max)
	DECLARE @last varchar(max)

	SET @first = (SELECT e.FirstName 
					FROM Employees e 
				   WHERE e.FirstName = @firstname and e.LastName = @lastname)

	SET @last = (SELECT LastName 
				   FROM Employees e
				  WHERE e.FirstName = @firstname and e.LastName = @lastname)

	SET @ConcatName = @first + ' ' + @last;
	RETURN @ConcatName;
END
GO

SELECT FirstName,LastName,DBO.f_MyCustomFuntion(FirstName,LastName) AS 'FullName' 
  FROM Employees

SELECT FirstName,LastName,CONCAT(FirstName,LastName) AS 'FullName' 
  FROM Employees

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 


SELECT e.FirstName,e.LastName, dbo.udf_get_salary (e.salary) salaryLevel FROM Employees e
GO
CREATE OR ALTER FUNCTION udf_get_salary (@Salary INT)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @level NVARCHAR(10)

	IF @Salary <= 30000 BEGIN
	  SET @level = 'LOW'
	END
	ELSE IF @Salary > 30000 AND @Salary <= 50000 BEGIN
	  SET @level = 'MEDIUM'
	END
	  ELSE BEGIN 
	SET @level = 'HIGH'
	END
	  RETURN @level 
END



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--																			CURSORS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
GO

-- SP_call_cursor is a procedure which create a trigger, the trigger calls another prosedure which select records for firstname, lastname and address from Employees table
EXEC SP_call_cursor
-- i purposelly type a wrong name which is not in the table Employee to show one interesting fact .This name does not have an address  so it won't return address info from this PROC
EXEC sp_GetRecords 'GoY', 'GILBERT',12500

GO

CREATE OR ALTER PROCEDURE SP_call_cursor

AS 
BEGIN
DECLARE @FirstName VARCHAR(MAX)
DECLARE @LastName VARCHAR(MAX)
DECLARE @Salary MONEY

DECLARE TestCursor CURSOR 
	FOR SELECT e.FirstName, e.LastName, e.Salary FROM Employees e 

OPEN TestCursor

	FETCH NEXT FROM TestCursor 
		INTO @FirstName, @LastName, @Salary
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC sp_GetRecords @FirstName, @LastName, @Salary
			FETCH NEXT FROM TestCursor
			INTO @FirstName, @LastName, @Salary
		END

CLOSE TestCursor
DEALLOCATE TestCursor

END

GO
CREATE OR ALTER PROCEDURE sp_GetRecords
(

@FirstName VARCHAR(MAX),
@LastName VARCHAR(MAX),
@Salary MONEY
)
AS
BEGIN
	DECLARE @Address VARCHAR(MAX)    SET @Address = (SELECT a.AddressText FROM Employees e join Addresses a ON a.AddressID = e.AddressID 
							                         WHERE e.FirstName = @FirstName AND e.LastName = @LastName AND e.Salary = @Salary) 
	PRINT 'Hello i am ' + @Firstname + ' ' + @LastName  
	PRINT 'This is my address: ' +  @Address 
	PRINT 'This is my salary: ' + CAST(@Salary AS VARCHAR(MAX)) 
	PRINT '====================='
END
GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
EXEC SP_CURSOR_TEST
GO
CREATE OR ALTER PROCEDURE SP_CURSOR_TEST 
 AS
 BEGIN
 DECLARE @FirstName VARCHAR(MAX)
 DECLARE @LastName VARCHAR(MAX)

     DECLARE CustomCursor CURSOR 
	FOR SELECT e.FirstName,e.LastName FROM Employees e ORDER BY e.FirstName

OPEN CustomCursor
	FETCH NEXT FROM CustomCursor
	INTO  @FirstName, @LastName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC SP_PRINT_EMPLOYEE_DETAILS @FirstName,@LastName
		FETCH NEXT FROM CustomCursor 
		INTO  @FirstName, @LastName
	END

CLOSE CustomCursor
DEALLOCATE CustomCursor
 END

GO

CREATE TABLE EXAMPLE_TABLE_RECORDS (
	Id INT PRIMARY KEY NOT NULL,
	RecordsCounter MONEY NOT NULL
)
INSERT INTO EXAMPLE_TABLE_RECORDS
VALUES
(1,0),
(2,0)
GO

CREATE OR ALTER PROC SP_PRINT_EMPLOYEE_DETAILS
(
  @FirstName VARCHAR(MAX),
  @LastName  VARCHAR(MAX)
)
AS 
BEGIN
 DECLARE @ExampleVariable INT          SET @ExampleVariable = 0;
 DECLARE @department_name VARCHAR(MAX) SET  @department_name = (SELECT d.name 
																		 FROM Employees e JOIN Departments d 
																		   ON d.DepartmentID = e.DepartmentID 
																		WHERE e.FirstName = @Firstname 
																		  and e.LastName = @LastName)
		PRINT 'Hello i am ' + @Firstname + ' ' + @LastName + ' from ' + @department_name + ' department' + ' !'
		PRINT '==============================================';
		
		SET @ExampleVariable += (SELECT e.Salary from Employees e WHERE e.FirstName = @Firstname and e.LastName = @LastName)
		UPDATE EXAMPLE_TABLE_RECORDS
		SET RecordsCounter += @ExampleVariable WHERE Id = 2;
END
GO
SELECT * FROM EXAMPLE_TABLE_RECORDS
SELECT * FROM Employees
-- |||||||||||||||||||||||||||||||||||||||||||||||||        3        ||||||||||||||||||||||||||||||||||||||||||||||||| 

-- ANOTHER OPTIONS - MOVE THROUGH EACH 10 ROW(IF WE USE -10 IT IS IN REVERSE ORDER)
DECLARE CustomCursor CURSOR SCROLL
	FOR SELECT e.FirstName,e.LastName FROM Employees e WHERE e.Salary > 30000

OPEN CustomCursor
	FETCH ABSOLUTE 10 FROM CustomCursor 	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		FETCH RELATIVE 10 FROM CustomCursor 

	END

CLOSE CustomCursor
DEALLOCATE CustomCursor
-- |||||||||||||||||||||||||||||||||||||||||||||||||        4        ||||||||||||||||||||||||||||||||||||||||||||||||| 

DECLARE @FullName NVARCHAR(MAX) SET @FullName = ''
DECLARE @FirstName NVARCHAR(MAX) 
DECLARE @LastName NVARCHAR(MAX) 



DECLARE CustomCursor CURSOR 
	FOR SELECT e.FirstName,e.LastName FROM Employees e WHERE e.Salary > 30000

OPEN CustomCursor
	FETCH NEXT FROM CustomCursor
	INTO  @FirstName, @LastName
	 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	     set @FullName = @FirstName +' ' + @LastName
		 print 'hello my full name is : ' + @FullName 
		FETCH NEXT FROM CustomCursor 
		INTO  @FirstName, @LastName

	END

CLOSE CustomCursor
DEALLOCATE CustomCursor


-- |||||||||||||||||||||||||||||||||||||||||||||||||        5        ||||||||||||||||||||||||||||||||||||||||||||||||| 

declare @Salary money;
declare @row_num bigint;

SELECT EmployeeID,
	   FirstName,
	   LastName,
	   Salary,
	   NULL as NextSalary,
	   ROW_NUMBER() OVER (ORDER BY employeeID) row_num
	   into #tempEmp
  FROM Employees 

DECLARE TestCursor CURSOR FOR 
	SELECT Salary, 
		   ROW_NUMBER() OVER (ORDER BY employeeID) row_num
	  FROM Employees 
  ORDER BY employeeID

OPEN TestCursor
FETCH NEXT FROM TestCursor INTO  @Salary, @row_num;

WHILE @@FETCH_STATUS = 0
BEGIN

	UPDATE #tempEmp
	SET NextSalary = @Salary
	WHERE row_num = @row_num - 1
	
	FETCH NEXT FROM TestCursor INTO  @Salary, @row_num
END

CLOSE TestCursor
DEALLOCATE TestCursor

select * from #tempEmp
drop table #tempEmp
-- |||||||||||||||||||||||||||||||||||||||||||||||||        6        ||||||||||||||||||||||||||||||||||||||||||||||||| 

GO




