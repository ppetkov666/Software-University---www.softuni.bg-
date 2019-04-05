
-- this querie consist the following : 
-- STORED PROCEDURES
-- TRIGGERS
-- FUNCTIONS
-- CURSORS
-- TRANSACTIONS


USE SoftUni
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                      STORED PROCEDURES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- CREATE PROCEDURE WITH TRY CATCH BLOCK AND TRANSACTION PLUS OUTPUT PARAM

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
  DECLARE @first VARCHAR(MAX)       --SET @first = (SELECT FirstName 
                                    --                FROM Employees e
                                    --               WHERE e.FirstName = @firstname 
                                    --                 AND e.LastName = @lastname)
  DECLARE @last VARCHAR(MAX)        --SET @last = (SELECT LastName 
                                    --               FROM Employees e
                                    --              WHERE e.FirstName = @firstname 
                                    --                AND e.LastName = @lastname)
 -- here is the advantage of using select when we set a variables because here we can set more than one variable only with one statement
 SELECT @first = FirstName , @last = LastName
   FROM Employees e 
  WHERE e.FirstName = @firstname
    AND e.LastName = @lastname 
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

-- i want to emphasise on one very important part : when we dont change the return code it will remain by default 0, 
-- but in the example below i will pusposely change it

GO
CREATE OR ALTER PROCEDURE f_my_custom_concat_procedure_version_return_type 
(
 @firstname VARCHAR(50),
 @lastname VARCHAR(50),
 @ConcatName VARCHAR(100) OUTPUT
)
AS
BEGIN
  
  DECLARE @first VARCHAR(MAX)                                    
  DECLARE @last VARCHAR(MAX)        
                                     
 SELECT @first = FirstName , @last = LastName
   FROM Employees e 
  WHERE e.FirstName = @firstname
    AND e.LastName = @lastname 
  
  SET @ConcatName = @first + ' ' + @last;

  IF @ConcatName = @ConcatName BEGIN
  RETURN 18
  END
  ELSE begin
  RETURN 23
  END
END

-- this is an example about return code of the store proc, output param and changed return code
DECLARE @error_code   int
DECLARE @FullName NVARCHAR(max)

EXEC @error_code   = f_my_custom_concat_procedure_version_return_type @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT
Select @@ERROR as error
SELECT @error_code   AS error_code
SELECT @FullName AS full_name

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- CREATE PROCEDURE WITH TRY CATCH BLOCK AND TRANSACTION
SELECT * FROM EmployeesProjects
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

EXEC dbo.udp_GetInfoWithExperienceInYears 18

GO

-- |||||||||||||||||||||||||||||||||||||||||||||||||        5        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- sp WITHOUT and WITH optional param
GO

CREATE OR ALTER PROCEDURE udp_add_numbers
(
  @first_number  INT,
  @second_number INT,
  @result        INT OUTPUT  
)
  -- when we add encryption this sp will be encrypted and once we try to open it we wont be able to see inside what contains as text
  WITH ENCRYPTION
AS
BEGIN
  SET @result = @first_number + @second_number
END  
 -- @result = @answer or just @answer on the param is the same 
DECLARE @answer INT
EXEC DBO.udp_add_numbers 10, 100, @answer OUTPUT 
SELECT CONCAT('the result is ',@answer) 'Final Answer'

GO

-- -----------------------------------------------------------
-- basically it tells : Give me id,firstname, lastname and jobtitle from this table WHERE
-- parameter is NULL OR the firstname is equal to the value of the paramm
-- SO it will give me only these records which i entered in the params, if all params are empthy and missing, their default value is NULL because i set it
-- and will give me all the records in this table
GO
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

 -- |||||||||||||||||||||||||||||||||||||||||||||||||        7        ||||||||||||||||||||||||||||||||||||||||||||||||| 
 -- CREATE A PROCEDURE WITH OUTPUT PARAM

CREATE OR ALTER PROCEDURE spe_with_output_param
(
 @department_name VARCHAR(50),
 @count_of_people INT OUTPUT
)
AS
BEGIN
                                     
  SELECT @count_of_people = COUNT(e.EmployeeID) 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
   WHERE d.[Name] = @department_name
END

DECLARE @count NVARCHAR(50)

EXEC spe_with_output_param  @department_name = 'Production' ,@count_of_people = @count OUTPUT
SELECT @count AS count_of_people_per_this_department

GO
-- in this case i can use return value of this sp also to return this count but:
-- in real world return value of sp is used only to check for success or failure of sp and specially with nested sp 
-- if we want to return something from sp we always use OUTPUT PARAM
DECLARE @count NVARCHAR(50)
declare @return_value INT
exec @return_value  = spe_with_output_param  @department_name = 'Production' ,@count_of_people = @count OUTPUT
select @return_value as return_value_from_sp  

-- |||||||||||||||||||||||||||||||||||||||||||||||||        7        ||||||||||||||||||||||||||||||||||||||||||||||||| 
 -- CREATE A PROCEDURE WITH @@error catch




Create Table Product_v1
(
 productid int NOT NULL primary key,
 [Name] nvarchar(50),
 price int,
 quantity int
)


Insert into Product_v1 
values
(1, 'productX', 500, 100),
(2, 'productY', 500, 150),
(3, 'productZ', 500, 200)

select * from Product_v1


Create Table Product_sales
(
 product_sales_id int primary key,
 product_id int,
 quantity_sold int
) 

go

Create or Alter Proc spe_sell_product
@product_id int,
@quantity_for_sell int
as
Begin
 
 Declare @stock_available int Select @stock_available = quantity 
                               from Product_v1 p where p.productid = @product_id
 
 
 if(@stock_available < @quantity_for_sell)
   Begin
  Raiserror('Not enough in Stock!!!',16,1)
   End
 
 Else
   Begin
    Begin Tran
         
  Update Product_v1 
     set quantity -= @quantity_for_sell
   where ProductId = @product_id
  
  Declare @maxproduct_id int
   
  Select @maxproduct_id = Case When isnull(MAX(product_sales_id), 0) = 0
                               Then 0 
                               else MAX(product_sales_id) end 
                          from Product_sales
  
  Set @maxproduct_id += 1
  Insert into Product_sales 
       values(@maxproduct_id, @product_id, @quantity_for_sell)
  if(@@ERROR <> 0)
  Begin
   Rollback Tran
   Print 'Error occured... Transaction was rollbacked'
   return
  End
  Else
  Begin
   Commit Tran 
   Print 'Committed Transaction'
  End
   End
End

-- test procedure :
Insert into Product_v1 
     values(2, 'ProductXXX', 1500, 10)
if(@@ERROR <> 0)
 Print 'Error !!!'
Else
 Print 'No Errors !!!'

 exec spe_sell_product 1, 10
 select * from Product_v1
 select * from Product_sales

--  same SP but modified with try catch block --------------------------------------
go
Create or Alter Proc spe_sell_product_with_try_catch
@product_id int,
@quantity_for_sell int
as
Begin
  Declare @stock_available int Select @stock_available = quantity 
                                 from Product_v1 p 
                                where p.productid = @product_id
 
  if(@stock_available < @quantity_for_sell)
  Begin
    Raiserror('Not enough in Stock!!!',16,1)
  End
 
 Else
  Begin try
    Begin Tran     
    Update Product_v1 
       set quantity -= @quantity_for_sell
     where ProductId = @product_id
   Declare @maxproduct_id int 
    Select @maxproduct_id = Case When isnull(MAX(product_sales_id), 0) = 0
                                 Then 0 
                                 else MAX(product_sales_id) end 
                            from Product_sales 
    Set @maxproduct_id += 1
    Insert into Product_sales 
         values(@maxproduct_id, @product_id, @quantity_for_sell)
  end try
  begin catch
    
  
End










-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                      TRIGERS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- update trigger
-- after insert/update/delete
-- instead of insert/update/delete

-- inserted and deleted tables lives in the scope of the trigger and has the structure of the tables which trigger use
-- they are temp tables 

GO

CREATE OR ALTER TRIGGER tr_townUpdate ON Towns FOR UPDATE
 AS
 BEGIN
  IF EXISTS(SELECT * 
              FROM inserted 
             WHERE ISNULL([Name],'') = '' OR LEN(NAME) = 0) 
  BEGIN
    RAISERROR('NAME CANNOT BE NULL OR EMPTHY',16,1)
    ROLLBACK
    RETURN 
  END
 END

   UPDATE Towns
      SET [NAME] = 'Seatle' 
     FROM Towns
    WHERE TownID = 1

  select * from Towns

 GO

 -- -------------------------------------------------------------------------

 CREATE OR ALTER TRIGGER tr_townInsert ON Towns FOR INSERT
 AS
 BEGIN 
  DECLARE @test BIT SET @test = 0 ;
      SET @test = (SELECT TownID 
                     FROM inserted 
                    WHERE LEN(NAME) < 3)
    IF  (@test = 1)
    BEGIN
    ROLLBACK
    RAISERROR('name cannot be less than 3 symbols',16,1)
    END
 END

 insert into Towns values ('woe')
 select * from Towns
 begin transaction
 delete  from Towns where TownID = 37
 commit

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
    JOIN deleted d 
    ON d.username = a.username
   WHERE d.Active = 'Y'
END 

DELETE FROM Accounts WHERE username = 'ivan'
SELECT * FROM Accounts
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                      FUNCTIONS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- these are SCALAR FUNCTIONS because they accept 0 or more params and return single value 
-- the advantage of functions are they can be used in SELECT or WHERE clause
-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 

CREATE OR ALTER FUNCTION f_MyCustomFuntion (@firstname VARCHAR(50),@lastname VARCHAR(50))
RETURNS VARCHAR(MAX)
WITH SCHEMABINDING
AS
BEGIN
  DECLARE @ConcatName varchar(max)
  DECLARE @first varchar(max)
  DECLARE @last varchar(max)

  SET @first = (SELECT e.FirstName 
                  FROM dbo.Employees e 
                 WHERE e.FirstName = @firstname and e.LastName = @lastname)

  SET @last = (SELECT LastName 
                 FROM dbo.Employees e
                WHERE e.FirstName = @firstname and e.LastName = @lastname)

  SET @ConcatName = @first + ' ' + @last;
  RETURN @ConcatName;
END
GO

-- when we use 'WITH SCHEMABINDING' we cannot drop the table because it is referenced
DROP TABLE dbo.Employees

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

-- this is inline function which return a table - it has a different syntax and can be used almost the same as parameterized views
-- INLINE TABLE VALUE FUNCTIONS HAVE BETTER PERFOMANCE COMPARED WITH MULTISTATEMENT TABLE VALUES FUNCTIONS, AND THEY CAN BE UPDATED
-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
GO
CREATE OR ALTER FUNCTION udf_get_people_by_department_name 
(
@department_name NVARCHAR(50)
)
RETURNS TABLE
AS

  RETURN(SELECT e.FirstName,e.LastName,d.[Name]
           FROM Employees e
           JOIN Departments d ON d.DepartmentID = e.DepartmentID
          WHERE d.[name] = @department_name) 
GO

SELECT * FROM  udf_get_people_by_department_name ('Marketing')
--BEGIN TRANSACTION
--UPDATE udf_get_people_by_department_name(1) SET NAME = 'TEST' WHERE FirstName = 'GUY'

-- multistatement table-------------------------------------------
select * from Employees

GO
CREATE OR ALTER FUNCTION udf_get_people_by_department_id
(
@department_id INT
)
RETURNS @table table(first_name varchar(50),last_name varchar(50))
AS
BEGIN
        insert into @table  SELECT e.FirstName,
                                   e.LastName
                              FROM Employees e
                             WHERE e.DepartmentID = @department_id

        return;
END
GO

select * from udf_get_people_by_department_id(15)



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                      CURSORS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
GO

-- SP_call_cursor is a procedure which create a cursor, the cursor calls another procedure which select records 
-- for firstname, lastname and address from Employees table
EXEC SP_call_cursor
-- i purposelly type a wrong name which is not in the table Employee to show one interesting fact.
-- This name does not have an address  so it won't return address info from this PROC
EXEC sp_GetRecords 'GoY', 'GILBERT',12500
-- and here i type it in the right way
EXEC sp_GetRecords 'Guy', 'GILBERT',12500


GO

CREATE OR ALTER PROCEDURE SP_call_cursor

AS 
BEGIN
DECLARE @FirstName VARCHAR(MAX)
DECLARE @LastName  VARCHAR(MAX)
DECLARE @Salary    MONEY

DECLARE TestCursor CURSOR FOR 
 SELECT e.FirstName, 
        e.LastName, 
        e.Salary 
   FROM Employees e 

OPEN TestCursor
  FETCH NEXT FROM TestCursor INTO @FirstName, @LastName, @Salary

  WHILE @@FETCH_STATUS <> -1
  BEGIN
    EXEC sp_GetRecords @FirstName, @LastName, @Salary
    FETCH NEXT FROM TestCursor INTO @FirstName, @LastName, @Salary
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
  DECLARE @Address VARCHAR(MAX)    SET @Address = (SELECT a.AddressText 
                                                     FROM Employees e 
                                                     JOIN Addresses a ON a.AddressID = e.AddressID 
                                                    WHERE e.FirstName = @FirstName AND 
                                                          e.LastName = @LastName   AND 
                                                          e.Salary = @Salary) 
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

  DECLARE CustomCursor CURSOR FOR  
   SELECT e.FirstName,
          e.LastName 
     FROM Employees e 
 ORDER BY e.FirstName

OPEN CustomCursor
  FETCH NEXT FROM CustomCursor INTO  @FirstName, @LastName
  WHILE @@FETCH_STATUS <> -1
  BEGIN
    EXEC SP_PRINT_EMPLOYEE_DETAILS @FirstName,@LastName
    FETCH NEXT FROM CustomCursor INTO  @FirstName, @LastName
  END
CLOSE CustomCursor
DEALLOCATE CustomCursor
END
GO


CREATE TABLE Salary_table (
  Id INT PRIMARY KEY  IDENTITY NOT NULL,
  full_name NVARCHAR(50) NOT NULL,
  salary MONEY
)
GO

CREATE OR ALTER PROC SP_PRINT_EMPLOYEE_DETAILS
(
  @FirstName VARCHAR(MAX),
  @LastName  VARCHAR(MAX)
)
AS 
BEGIN
 
 DECLARE @salary            INT                    SET @salary = 0;
 DECLARE @full_name         NVARCHAR(50)           SET @full_name = '';
 DECLARE @exist             INT                    SET @exist = 0;

 DECLARE @department_name VARCHAR(MAX) SET @department_name = (SELECT TOP(1)d.[name] 
                                                                 FROM Employees e 
                                                                 JOIN Departments d ON d.DepartmentID = e.DepartmentID 
                                                                WHERE e.FirstName = @Firstname 
                                                                  AND e.LastName = @LastName)
    PRINT 'Hello i am ' + @Firstname + ' ' + @LastName + ' from ' + @department_name + ' department' + ' !'
    PRINT '==============================================';

    SELECT @full_name = @FirstName + ' ' + @LastName;

    SELECT TOP(1)@salary = e.Salary
      FROM Employees e
     WHERE e.FirstName = @FirstName
       AND e.LastName = @LastName
    
    SELECT @exist  = 1                      
      FROM Salary_table st 
     WHERE st.full_name = @full_name
       AND st.salary = @salary
    
    IF(@exist = 0)
    BEGIN
    INSERT INTO Salary_table 
    VALUES
    (@full_name,@salary)
    END
END
GO

EXEC SP_CURSOR_TEST
SELECT * FROM Salary_table
DELETE FROM Salary_table
TRUNCATE table Salary_table
SELECT * FROM Employees
-- |||||||||||||||||||||||||||||||||||||||||||||||||        3        ||||||||||||||||||||||||||||||||||||||||||||||||| 

-- ANOTHER OPTIONS - MOVE THROUGH EACH 10 ROW(IF WE USE -10 IT IS IN REVERSE ORDER)
DECLARE CustomCursor CURSOR SCROLL FOR 
 SELECT e.FirstName,
        e.LastName 
   FROM Employees e 
  WHERE e.Salary > 30000

OPEN CustomCursor
  FETCH ABSOLUTE 10 FROM CustomCursor   
  WHILE @@FETCH_STATUS <> -1
  BEGIN
    FETCH RELATIVE 10 FROM CustomCursor 
  END
CLOSE CustomCursor
DEALLOCATE CustomCursor

select * from employees e where e.salary > 30000 
-- |||||||||||||||||||||||||||||||||||||||||||||||||        4        ||||||||||||||||||||||||||||||||||||||||||||||||| 

DECLARE @FullName NVARCHAR(MAX) SET @FullName = ''
DECLARE @FirstName NVARCHAR(MAX) 
DECLARE @LastName NVARCHAR(MAX) 



DECLARE CustomCursor CURSOR FOR 
 SELECT e.FirstName,
        e.LastName 
   FROM Employees e 
  WHERE e.Salary > 30000
OPEN CustomCursor
  FETCH NEXT FROM CustomCursor INTO  @FirstName, @LastName
  WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @FullName = @FirstName +' ' + @LastName
    PRINT 'hello my full name is : ' + @FullName 
    FETCH NEXT FROM CustomCursor INTO  @FirstName, @LastName
  END
CLOSE CustomCursor
DEALLOCATE CustomCursor


-- |||||||||||||||||||||||||||||||||||||||||||||||||        5        ||||||||||||||||||||||||||||||||||||||||||||||||| 
go
  DECLARE @Salary INT;
  DECLARE @row_num BIGINT;

  SELECT EmployeeID,
         FirstName,
         LastName,
         Salary,
         NULL AS NextSalary,
         ROW_NUMBER() OVER (ORDER BY employeeID) row_num
    INTO #tempEmp
    FROM Employees 

SELECT * FROM #tempEmp

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

SELECT * FROM #tempEmp
DROP TABLE #tempEmp


-- the same querie but wrapped in SP
GO
create or alter proc sp_get_next_salary_with_cursor

as
begin
  DECLARE @Salary INT;
  DECLARE @row_num BIGINT;

  SELECT EmployeeID,
         FirstName,
         LastName,
         Salary,
         NULL AS NextSalary,
         ROW_NUMBER() OVER (ORDER BY employeeID) row_num
    INTO #tempEmp
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

  SELECT * FROM #tempEmp
   DROP TABLE #tempEmp
end


exec sp_get_next_salary_with_cursor







-- |||||||||||||||||||||||||||||||||||||||||||||||||        6        ||||||||||||||||||||||||||||||||||||||||||||||||| 

 
 -- temp table - it shows how after update - the changed field is only in the temp table but not in the original one 

SELECT EmployeeID,
       FirstName,
       LastName,
       Salary,
       NULL AS NextSalary,
       ROW_NUMBER() OVER (ORDER BY employeeID) row_num
  INTO temp_result_table
  FROM Employees 

UPDATE temp_result_table
   SET Salary = 12500
 WHERE FirstName = 'Guy' and LastName = 'Gilbert'

SELECT * FROM temp_result_table
SELECT * FROM employees
DROP TABLE temp_result_table


GO

DECLARE @Salary   INT;    SET @Salary = 0
DECLARE @row_num  INT     SET @row_num = 1;
DECLARE @num      INT     SET @num = 0
DECLARE @id_count INT     SET @id_count = (SELECT COUNT(employeeId) FROM Employees)

WHILE(@num <= @id_count)
BEGIN 
  SET @num +=1
  SET @Salary  = (SELECT Salary 
                    FROM temp_result_table 
                   WHERE row_num = @row_num)
   PRINT @salary
  UPDATE temp_result_table
     SET NextSalary = @Salary
   WHERE row_num = @row_num -1
     SET @row_num += 1
END


SELECT * FROM temp_result_table
SELECT * FROM employees

-- |||||||||||||||||||||||||||||||||||||||||||||||||        7        ||||||||||||||||||||||||||||||||||||||||||||||||| 

select max(unit_price) from product_sales_test pst
select * from products_test

create or alter proc spe_test_proc

AS
BEGIN
DECLARE @product_id INT
DECLARE @unit_price INT
DECLARE @id INT
DECLARE @price INT



DECLARE test_cursor CURSOR FOR 
 SELECT product_id, 
        unit_price 
   FROM dbo.product_sales_test
OPEN test_cursor 
  FETCH NEXT FROM test_cursor INTO @product_id, @unit_price
  WHILE @@FETCH_STATUS <> -1
  BEGIN
    
    IF(@unit_price < 10)
    BEGIN
      UPDATE products_test
      SET name += ', ' + cast (@unit_price AS NVARCHAR(max)) where id = @product_id
    END 
    IF(@unit_price > 10 and @unit_price < 40)
    BEGIN
      UPDATE products_test
      SET name += ', ' + cast (@unit_price AS NVARCHAR(max)) where id = @product_id
    END 
    FETCH NEXT FROM test_cursor INTO @product_id, @unit_price

  END 
CLOSE test_cursor 
DEALLOCATE test_cursor 
END
exec spe_test_proc

select * from products_test

-- THE SAME RESULT SET BUT WITH JOIN AND STUFF + XML PATH 
-- it could be with stuff finction or replace or... even without any function
--stuff: start from position 1 , and replace next 1 symbol with '' - this is what it does in my particular case
GO
 
 with cte_test
 as
 (
  SELECT pt.ID, 
         STUFF((SELECT ', ' + CAST(pst.unit_price AS varchar(10))
                  FROM product_sales_test AS pst  
                 WHERE pst.product_id = pt.ID 
                   AND (pst.unit_price < 10  OR (pst.unit_price > 10 AND pst.unit_price < 40))
                   FOR XML PATH('')),1,1,'') AS Ids
    FROM products_test AS pt
GROUP BY pt.ID
)

update products_test
   set Name = CONCAT(pt.[Name],  cast (ct.Ids AS NVARCHAR(2048)))
   from products_test pt
  join cte_test ct on ct.Id = pt.Id 
  where Ids is not null

select * from products_test
select * from product_sales_test pst order by product_id


  -- IT DOES NOT WORK THE SAME WAY AS THE CURSOR
UPDATE products_test
SET Name = Name + '..., ' + cast (PST.unit_price AS NVARCHAR(max))
  FROM products_test pt
  join product_sales_test pSt on pt.Id = PST.product_id
  WHERE (PST.unit_price < 10  OR PST.unit_price > 10 AND PST.unit_price < 40) 





select   STUFF((SELECT ', ' + CAST(' 111' AS varchar(10)) FOR XML PATH('')),1,1,'') AS Ids


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                             TRANSACTIONS
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                            
                                                            
-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
                                       -- HOW TO explain diffference between blocking and deadlocking

--  BLOCKING 
use UserInfo
select * from UserInfoTable
select * from People

begin transaction

update UserInfoTable 
SET FirstName = 'testname' 
where id = 27 

commit transaction

-- if i execute the same transaction from new querie  it will wait until this transaction is committed and then the second transaction will be executed

-- DEADLOCKING
-- in the following example if i execute from this session the UserInfoTable table and from another session the People table , these 2 tables will be locked, 
-- then when i try to execute table People from this session and accordingly UserInfoTable from the other session the deadlock will occur and sql server will 
-- choose one of both transactions as deadlock victim and it will be rollbacked and the other will be completed 
begin transaction

update UserInfoTable 
SET FirstName = 'testname' 
where id = 27 

update People
set Firstname = 'testname'
where id = 2
rollback
commit transaction

select @@trancount  -- check the number of active transactions

-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- when i update one row from this table with transaction from other connection still can access another row from this table, 
-- because when i update by primary key only the current row is LOCKED. From another connection i can access another rows , but not the whole table
SELECT * FROM UserInfoTable
BEGIN TRANSACTION
UPDATE UserInfoTable
SET Salary = 6666666 WHERE ID = 27
ROLLBACK
SELECT * FROM People


