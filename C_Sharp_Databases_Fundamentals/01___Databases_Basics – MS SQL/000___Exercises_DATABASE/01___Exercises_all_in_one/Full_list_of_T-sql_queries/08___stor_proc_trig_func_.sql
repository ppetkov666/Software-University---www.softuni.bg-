

-- 001 - STORED PROCEDURES
-- 002 - TRIGGERS
-- 003 - FUNCTIONS
-- 004 - CURSORS
-- 005 - TRANSACTIONS


USE SoftUni
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                   001 - STORED PROCEDURES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO

sp_help spe_get_custom_report
go
sp_helptext spe_get_custom_report
go
sp_depends spe_get_custom_report
go




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
  SET @ConcatName = @first + ' ' + @last + 1;
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

  DECLARE @v_sql_error_number                             INT;
  DECLARE @v_sql_error_severity                             INT;
  DECLARE @v_sql_error_state                                INT;
  DECLARE @v_sql_error_procedure                            NVARCHAR(126);
  DECLARE @v_sql_error_line                                 INT;
  DECLARE @v_sql_error_message                              NVARCHAR(2048);
 
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


  --THROW;
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
declare @return_code int
exec @return_code =  f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT
SELECT @FullName AS fullname
select @return_code

DECLARE @FullName NVARCHAR(50)
exec f_MyCustomConcatProcedure @firstname = 'guy', @lastname = 'gilbert', @ConcatName = @FullName OUTPUT
select @FullName
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

  -- BY DEFAULT THE RETURN CODE IS 0 - indicating success
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
  DECLARE @max_employee_projects_count INT  SET @max_employee_projects_count = 6
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
 
 Declare @stock_available int             Select @stock_available = quantity 
                                            from Product_v1 p 
                                           where p.productid = @product_id
 
 
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
  
  -- i am having this maxproduct_id because the field is not identity 
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
CREATE OR ALTER PROC spe_sell_product_with_try_catch
@product_id        INT,
@quantity_for_sell INT
AS
BEGIN
  DECLARE @stock_available                                  INT          SELECT @stock_available = quantity 
                                                                           FROM Product_v1 p 
                                                                          WHERE p.productid = @product_id
  DECLARE @maxproduct_id                                    INT             SET @maxproduct_id = 0
  DECLARE @v_no_error                                       BIT             SET @v_no_error = 1
  DECLARE @v_sql_error_number                               INT;
  DECLARE @v_sql_error_severity                             INT;
  DECLARE @v_sql_error_state                                INT;
  DECLARE @v_sql_error_procedure                            NVARCHAR(126);
  DECLARE @v_sql_error_line                                 INT;
  DECLARE @v_sql_error_message                              NVARCHAR(2048);

  BEGIN TRY 
  BEGIN TRAN
  IF(@stock_available < @quantity_for_sell)
  BEGIN
    SET @v_no_error = 0
    RAISERROR('Not enough in Stock!!!',16,1)
  END
 
 ELSE
  BEGIN
    UPDATE Product_v1 
       SET quantity -= @quantity_for_sell
     WHERE ProductId = @product_id
    
    SELECT @maxproduct_id = CASE WHEN ISNULL(MAX(product_sales_id), 0) = 0
                                 THEN 0 
                                 ELSE MAX(product_sales_id) END 
                            FROM Product_sales 
    Set @maxproduct_id += 1
    INSERT INTO Product_sales 
         VALUES(@maxproduct_id, @product_id, @quantity_for_sell)
   END
  END TRY
  BEGIN CATCH
    SET @v_no_error = 0

 SELECT @v_sql_error_number = ERROR_NUMBER(), 
      @v_sql_error_severity = ERROR_SEVERITY(), 
      @v_sql_error_state = ERROR_STATE(), 
      @v_sql_error_procedure = ERROR_PROCEDURE(), 
      @v_sql_error_line = ERROR_LINE(), 
      @v_sql_error_message = ERROR_MESSAGE();

  END CATCH

  IF NOT (@v_no_error = 0 )
    BEGIN
      PRINT 'no errors - transaction will be commited!'
      COMMIT TRAN
    END
    ELSE IF XACT_STATE() <> 0
    BEGIN
      SELECT @v_sql_error_number   AS 'error number',
             @v_sql_error_severity AS 'error_severity',   
             @v_sql_error_state    AS 'error_state',
             @v_sql_error_line     AS 'error_line ',
             @v_sql_error_message  AS 'error_message'
      ROLLBACK
    END
END
rollback

exec spe_sell_product_with_try_catch 2, 10
 select * from Product_v1
 select * from Product_sales





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                  002 - TRIGERS 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- |||||||||||||||||||||||||||||||||||||||||||||||||        1        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- DML triggers
-- AFTER(FOR) insert/update/delete - they are fired after insert, update or delete execution
-- INSTEAD OF insert/update/delete - they are fired INSTEAD OF triggering action(insert, update or delete) 

-- INSERTED and DELETED tables lives in the scope of the trigger and has the structure of the tables which trigger use
-- they are TEMP TABLES 
use SoftUni
select * from Towns
GO


-----------------------------------------------------------------------------------
 -- FOR INSERT 
-----------------------------------------------------------------------------------

CREATE OR ALTER TRIGGER tr_townInsert ON Towns FOR INSERT
 AS
 BEGIN 
  DECLARE @town_inserted BIT SET @town_inserted = 0 ;
    SELECT TOP 1 @town_inserted = (SELECT 1 
                                     FROM inserted 
                                    WHERE LEN([NAME]) <= 3)
    IF (@town_inserted = 1)
    BEGIN
    ROLLBACK
    RAISERROR('name cannot be less ?r equal to 3 symbols',16,1)    
    END
    SELECT * FROM inserted
 END


 insert into Towns 
 values ('SrF')
 select * from Towns
 begin transaction
 delete  from Towns where Name = 'woe'
 commit
 select * from Towns


 use SoftUni
 go
 create table Log_Table
 (
 id int primary key identity,
 log_info nvarchar(200)
 )

 -- ///////////////////////
 --      EXAMPLE  2
 -- ///////////////////////


 go
 CREATE OR ALTER TRIGGER tr_townInsert_v_2 ON Towns FOR INSERT
 AS
 BEGIN

  DECLARE @town_name NVARCHAR(50) 
  DECLARE @town_id INT 
  DECLARE @insert_town_info NVARCHAR(200)

  -- it could be done with mass insert or cursor but mass Iinsert is bad practice in this case !
  --insert into Log_Table select cast(i.TownID as nvarchar(10)) +' ' + i.Name from inserted i
 DECLARE insert_cursor CURSOR FOR 
 SELECT i.TownID,
        i.[Name]
   FROM inserted i 

  OPEN insert_cursor
  FETCH NEXT FROM insert_cursor INTO @town_id, @town_name

  WHILE @@FETCH_STATUS <> -1
  BEGIN
  
  select @insert_town_info = 'town with name: ' + cast(@town_name as nvarchar(50)) + ' and id: ' +
  CAST(@town_id as nvarchar(5)) + ' were inserted at ' + CAST(GETDATE() as nvarchar(50))
  insert into Log_Table
  values
  (@insert_town_info)

    FETCH NEXT FROM insert_cursor INTO @town_id, @town_name
  END
CLOSE insert_cursor
DEALLOCATE insert_cursor
   
 END

 begin tran
 insert into Towns
 values
 ('town 3'),
 ('town 4'),
 ('town 5')

 rollback
 select * from Towns
 select * from Log_Table
-----------------------------------------------------------------------------------
 -- FOR UPDATE 
-----------------------------------------------------------------------------------
GO
CREATE OR ALTER TRIGGER tr_townUpdate ON Towns FOR UPDATE
 AS
 BEGIN

  -- FIRST APPROACH
  --declare @old_name nvarchar(50)
  --declare @new_name nvarchar(50)
  --select @new_name = I.[Name] FROM inserted I
  --select @old_name = d.[Name] FROM deleted d
  --if @new_name = @old_name 
  --  begin
  --    raiserror('you must use different name in case of update',16,1)
  --    rollback
  --  end
  
  -- SECOND APPROACH
  --if exists(select 1 
  --            from inserted i
  --            join deleted d on d.TownID = i.TownID
  --            where i.[Name] = d.[Name] )
  --  begin
      
  --    raiserror('you must use different name in case of update',16,1)
  --    rollback
  --  end

  -- THIRD and the best one approach
    DECLARE @v_exists BIT SET @v_exists = 0

    SELECT TOP 1 @v_exists  = 1  
      FROM inserted i
      JOIN deleted d ON d.TownID = i.TownID
     WHERE i.[Name] = d.[Name]

     IF @v_exists = 1
      BEGIN
        RAISERROR('Error while trying to update with the same data',16,1)
        ROLLBACK
      END

  IF EXISTS(SELECT 1 
              FROM inserted 
             WHERE ISNULL([Name],'') = '' OR LEN(NAME) = 0) 
    BEGIN
      RAISERROR('NAME CANNOT BE NULL OR EMPTHY',16,1)
      ROLLBACK
      RETURN 
    END
  --select * from inserted
  --select * from deleted
 END
  
   UPDATE Towns
      SET [NAME] = 'S o f i a' 
     FROM Towns
    WHERE TownID = 39
    

  select * from Towns
 GO




 -- ///////////////////////
 --      EXAMPLE  2
 -- ///////////////////////



SELECT * FROM Employees
select * from Log_table_employees
GO
CREATE or ALTER TRIGGER tr_tbl_employee_for_update ON Employees FOR UPDATE
AS
BEGIN
  -- Declare variables to hold old and updated data
  DECLARE @v_id             INT
  DECLARE @v_old_name       NVARCHAR(50)
  DECLARE @v_new_name       NVARCHAR(50)
  DECLARE @v_old_salary     INT
  DECLARE @v_new_salary     INT
  DECLARE @v_old_job_title  NVARCHAR(50) 
  DECLARE @v_new_job_title  NVARCHAR(50)
  DECLARE @v_old_deptId     INT 
  DECLARE @v_new_deptId     INT  
  Declare @v_log_string     NVARCHAR(1000) 
  
  -- Load the updated records into temporary table
  --SELECT *
  --INTO #TempTable
  --FROM inserted
  
  -- here i will provide 2 approach: WHILE LOOP and CURSOR

  --While(Exists(Select EmployeeID from #TempTable))
  --Begin
  --  --Initialize the audit string to empty string
  --  
    
  --  -- Select first row data from temp table
  --  Select Top 1 @v_id = EmployeeID, 
  --               @v_new_name = FirstName, 
  --               @v_new_job_title = JobTitle, 
  --               @v_new_salary = Salary,
  --               @v_new_deptId = DepartmentId
  --  from #TempTable
    
  --  -- Select the corresponding row from deleted table
  --  Select @v_old_name = FirstName, 
  --         @v_old_job_title = JobTitle, 
  --         @v_old_salary = Salary, 
  --         @v_old_deptId = DepartmentId
  --    from deleted 
  --   where EmployeeID = @v_id
    
  --     -- Build the log string dynamically           
  --  Set @v_log_string = 'Employee with Id = ' + Cast(@v_id as nvarchar(4)) + ' changed'
  --  if(@v_old_name <> @v_new_name)
  --    Set @v_log_string = @v_log_string + ' FirstName from ' + 
  --    @v_old_name + ' to ' + @v_new_name
         
  --  if(@v_old_job_title <> @v_new_job_title)
  --    Set @v_log_string = @v_log_string + ' JobTitle from ' + 
  --    @v_old_job_title + ' to ' + @v_new_job_title
         
  --  if(@v_old_salary <> @v_new_salary)
  --    Set @v_log_string = @v_log_string + ' SALARY from ' + 
  --    Cast(@v_old_salary as nvarchar(10))+ ' to ' + Cast(@v_new_salary as nvarchar(10))
          
  --  if(@v_old_deptId <> @v_new_deptId)
  --    Set @v_log_string = @v_log_string + ' DepartmentId from ' + 
  --    Cast(@v_old_deptId as nvarchar(10))+ ' to ' + Cast(@v_new_deptId as nvarchar(10))
    
  --  insert into Log_table_employees 
  --  values
  --  (@v_log_string)
    
  --  -- Delete the row from temp table, so we can move to the next row
  --  Delete from #TempTable 
  --   where EmployeeID = @v_id
  --End


  --Initialize the audit string to empty string
  DECLARE log_cursor CURSOR 
      FOR 
   SELECT i.EmployeeID, 
          i.FirstName, 
          i.JobTitle,
          i.Salary,
          i.DepartmentID
     FROM inserted i
     
    OPEN log_cursor
    FETCH NEXT FROM log_cursor INTO @v_id, 
                                    @v_new_name, 
                                    @v_new_job_title,
                                    @v_new_salary,
                                    @v_new_deptId
    WHILE @@FETCH_STATUS <> -1
  BEGIN

    SELECT @v_old_name = FirstName, 
           @v_old_job_title = JobTitle, 
           @v_old_salary = Salary, 
           @v_old_deptId = DepartmentId
      FROM deleted 
     WHERE EmployeeID = @v_id
    
    if(@v_new_name      = @v_old_name      and 
       @v_new_job_title = @v_old_job_title and 
       @v_new_salary = @v_old_salary       and 
       @v_new_deptId = @v_old_deptId)
       BEGIN
         SET @v_log_string = 'no changes has beed made!'
       END
    ELSE
    BEGIN
       -- Build the log string dynamically           
    SET @v_log_string = 'Employee with Id = ' + CAST(@v_id AS NVARCHAR(4)) + ' changed'
    IF(@v_old_name <> @v_new_name)
      SET @v_log_string = @v_log_string + '   FirstName from ' + 
      @v_old_name + ' to ' + @v_new_name
         
    IF(@v_old_job_title <> @v_new_job_title)
      SET @v_log_string = @v_log_string + ',   JobTitle from ' + 
      @v_old_job_title + ' to ' + @v_new_job_title
         
    IF(@v_old_salary <> @v_new_salary)
      SET @v_log_string = @v_log_string + ',   SALARY from ' + 
      CAST(@v_old_salary AS NVARCHAR(10))+ ' to ' + CAST(@v_new_salary AS NVARCHAR(10))
          
    IF(@v_old_deptId <> @v_new_deptId)
      SET @v_log_string = @v_log_string + ',   DepartmentId from ' + 
      CAST(@v_old_deptId AS NVARCHAR(10))+ ' to ' + CAST(@v_new_deptId AS NVARCHAR(10))
    END

    INSERT INTO Log_table_employees 
    VALUES
    (@v_log_string)
    
    -- Delete the row from temp table, so we can move to the next row
    FETCH NEXT FROM log_cursor INTO @v_id, 
                                    @v_new_name, 
                                    @v_new_job_title,
                                    @v_new_salary,
                                    @v_new_deptId
  END
  CLOSE log_cursor
  DEALLOCATE log_cursor
END

begin tran
update Employees
  set FirstName = 'Petko',
      JobTitle = 'CEO',
      DepartmentID = '2',
      Salary = 0
  where EmployeeID in (1,2,3,4)
rollback

SELECT * FROM Employees
select * from Log_table_employees


 -----------------------------------------------------------------------------------
 -- FOR DELETE
-----------------------------------------------------------------------------------
use master
GO
CREATE OR ALTER TRIGGER tr_AddressDelete ON Accounts FOR DELETE
 AS
 BEGIN
  IF EXISTS(SELECT 1 
              FROM deleted 
             WHERE username LIKE 'p%') 
  BEGIN
    RAISERROR('You can''t delete Accounts username starting with P',16,1)
    ROLLBACK
    RETURN 
  END
 END
 BEGIN TRAN
   DELETE FROM  Accounts
    WHERE username like 'p%'
ROLLBACK
  select * from Accounts
  


 GO
 
 -----------------------------------------------------------------------------------
 -- INSTEAD OF DELETE
-----------------------------------------------------------------------------------

 GO
 CREATE TABLE Accounts(
  username VARCHAR(10) NOT NULL PRIMARY KEY,
  [password] VARCHAR(20) NOT NULL,
  Active CHAR(1) NOT NULL DEFAULT 'Y' 
 )
 GO
 INSERT INTO Accounts
VALUES
('petko','123456','y'),
('ivan','1234','y'),
('georgi','12345','y')
GO
SELECT * FROM Accounts 

GO
CREATE OR ALTER TRIGGER TR_DELETE ON Accounts INSTEAD OF DELETE 
AS 
BEGIN 

  UPDATE a
     SET a.Active = 'N'
    FROM Accounts a 
    JOIN deleted d ON d.username = a.username
   WHERE d.Active = 'Y'
END 

BEGIN TRAN
DELETE FROM Accounts WHERE username = 'ivan'
SELECT * FROM Accounts

rollback
GO


-----------------------------------------------------------------------------------
 -- INSTEAD OF INSERT (insert into VIEW)
-----------------------------------------------------------------------------------
-- in this particular case without trigger we CAN'T insert into this view
go

SET IDENTITY_INSERT employees ON
SELECT * FROM v_emp_dep
go
create or alter view v_emp_dep
as
(
  select e.EmployeeID,
         e.firstname,
         e.lastname,
         d.name as department_name
    from employees e
    join departments d on d.departmentID = e.departmentID
    
)
go
select * from v_emp_dep

go
create or alter trigger tr_instead_of_insert on v_emp_dep instead of insert  
as
begin

   declare @dep_id int
   select @dep_id  = DepartmentID from departments d  
                                  join inserted i on i.department_name = d.[name]

  if (@dep_id is null)
    begin
      raiserror('there is no such a department!', 16,1)
      rollback
      return
    end
  -- some fields are hard coded just because this is test example                  
    insert into employees(EmployeeID,FirstName,LastName,MiddleName,JobTitle,DepartmentID,HireDate,Salary,AddressID)
    select i.EmployeeID,
           i.firstname, 
           i.lastname,
           'p',
           'ceo',
           @dep_id,
           '2019',
           0,
           166 
      from inserted i
    
      
end
go  

begin tran
insert into v_emp_dep
values
(296,'petko','petkov','Engineering')
rollback
commit
SET IDENTITY_INSERT employees OFF
 select * from departments
 select * from employees

-----------------------------------------------------------------------------------
 -- INSTEAD OF UPDATE
-----------------------------------------------------------------------------------

select * from v_emp_dep
select * from Employees
select * from Departments
go
CREATE OR ALTER TRIGGER tr_instead_of_update ON v_emp_dep INSTEAD OF UPDATE  
AS
BEGIN
 
 IF(UPDATE(employeeID))
 BEGIN
  RAISERROR('Emoloyee ID cannot be modified!',16,1)
  RETURN
 END

 IF (UPDATE(department_name))
 BEGIN
   DECLARE @dep_id INT
    SELECT @dep_id  = DepartmentID 
      FROM departments d  
      JOIN inserted i ON i.department_name = d.[name]
                                 
    IF (@dep_id IS NULL)
    BEGIN
      RAISERROR('there is no such a department!', 16,1)
      RETURN
    END
    UPDATE Employees
       SET DepartmentID = @dep_id
      FROM Employees e
      JOIN inserted i on i.EmployeeID = e.EmployeeID       
  END

  IF(UPDATE(firstname))
    BEGIN
      DECLARE @firstname NVARCHAR(50)
      SELECT @firstname = i.FirstName 
        FROM inserted i
        
      UPDATE e
         SET e.FirstName = @firstname
        FROM Employees e
        JOIN inserted i ON i.EmployeeID = e.EmployeeID

      -- another syntax
      --update e
      --   set e.FirstName = i.FirstName
      --  from inserted i
      --  join Employees e
      --    on e.EmployeeID = i.EmployeeID
    END

    IF(UPDATE(lastname))
    BEGIN
      DECLARE @lastname NVARCHAR(50)
      SELECT @lastname = i.LastName 
        FROM inserted i
        
      UPDATE e
         SET e.LastName = @lastname
        FROM Employees e
        JOIN inserted i ON i.EmployeeID = e.EmployeeID
    END
END
go

begin tran
update vep
   set department_name = 'Tool Design'
  from v_emp_dep vep
 where EmployeeID = 1
rollback

begin tran
update vep
   set FirstName = 'first_name_change_test'
  from v_emp_dep vep
 where EmployeeID = 1
rollback

begin tran
update vep
   set LastName = 'last_name_change_test'
  from v_emp_dep vep
 where EmployeeID = 1
rollback

begin tran
update vep
   set EmployeeID = 300
  from v_emp_dep vep
 where EmployeeID = 1
rollback


select * from v_emp_dep
select * from Employees
select * from Departments


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                              003 - FUNCTIONS 
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
--                                                                  004 - CURSORS 
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
    
    IF NOT (@exist = 1)
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
use student_test_db

select max(unit_price) from product_sales_test pst
select * from products_test

go
create or alter proc spe_test_proc

AS
BEGIN
  DECLARE @product_id INT
  DECLARE @unit_price INT
  DECLARE @id INT
  DECLARE @price INT
  
  select * from dbo.product_sales_test order by product_id
  select * from products_test
  
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
      IF(@unit_price > 10 and @unit_price <= 50)
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
                   AND (pst.unit_price < 10  OR (pst.unit_price > 10 AND pst.unit_price <= 50))
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
--                                                                005 - TRANSACTIONS
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

-- if i execute the same transaction from new querie  it will wait until this transaction is committed and then 
-- the second transaction will be executed

-- DEADLOCKING
-- in the following example if i execute from this session the UserInfoTable table and from another session the People table , 
-- these 2 tables will be locked, then when i try to execute table People from this session and accordingly UserInfoTable 
-- from the other session the deadlock will occur and sql server will choose one of both transactions as deadlock victim 
-- ,it will be rollbacked and the other will be completed!!!... 
-- one important addition - we are talking about lock by primary key!!!

-- the other sp used to simulate deadlock from another connection is located at 00_test_querie / 
-- 001 -  -- TEST QUERIE FOR TRANSACTION TO SIMULATE DEADLOCK
set deadlock_priority NORMAL
execute sp_readerrorlog
go
CREATE OR ALTER PROCEDURE sp_tran_one
AS
BEGIN
  BEGIN TRANSACTION
  BEGIN TRY 
  UPDATE UserInfoTable 
     SET FirstName = 'testname' + ' transaction 1'
   WHERE id = 27 
  
  WAITFOR DELAY '00:00:05'
  
  UPDATE People
     SET Firstname = 'testname' + ' transaction 1'
   WHERE id = 2
  COMMIT TRANSACTION
  SELECT 'Transaction completed !'
  END TRY 
  BEGIN CATCH 
    IF (ERROR_NUMBER() = 1205 )
      BEGIN
        SELECT 'Deadlock. Transaction failed.'
      END
      ROLLBACK
  END CATCH 
END

exec sp_tran_one

select @@trancount  -- check the number of active transactions
select * from UserInfoTable

dbcc opentran -- check the last active transaction

begin tran
update UserInfoTable
  set Salary += 30
  where id = 27
rollback

-- active transactions script info
SELECT
    [s_tst].[session_id],
    [s_es].[login_name] AS [Login Name],
    DB_NAME (s_tdt.database_id) AS [Database],
    [s_tdt].[database_transaction_begin_time] AS [Begin Time],
    [s_tdt].[database_transaction_log_bytes_used] AS [Log Bytes],
    [s_tdt].[database_transaction_log_bytes_reserved] AS [Log Rsvd],
    [s_est].text AS [Last T-SQL Text],
    [s_eqp].[query_plan] AS [Last Plan]
FROM
    sys.dm_tran_database_transactions [s_tdt]
JOIN
    sys.dm_tran_session_transactions [s_tst]
ON
    [s_tst].[transaction_id] = [s_tdt].[transaction_id]
JOIN
    sys.[dm_exec_sessions] [s_es]
ON
    [s_es].[session_id] = [s_tst].[session_id]
JOIN
    sys.dm_exec_connections [s_ec]
ON
    [s_ec].[session_id] = [s_tst].[session_id]
LEFT OUTER JOIN
    sys.dm_exec_requests [s_er]
ON
    [s_er].[session_id] = [s_tst].[session_id]
CROSS APPLY
    sys.dm_exec_sql_text ([s_ec].[most_recent_sql_handle]) AS [s_est]
OUTER APPLY
    sys.dm_exec_query_plan ([s_er].[plan_handle]) AS [s_eqp]
ORDER BY
    [Begin Time] ASC;
GO



-- |||||||||||||||||||||||||||||||||||||||||||||||||        2        ||||||||||||||||||||||||||||||||||||||||||||||||| 
-- when i update by primary key one row from this table with transaction, 
-- from other connection still can access another row from this table, because when i update by primary key 
-- only the current row is LOCKED. 
-- From another connection i can access another rows , but not the one who is being updated
SELECT * FROM UserInfoTable
SELECT * FROM People

BEGIN TRANSACTION
UPDATE UserInfoTable
SET Salary = 6666666 WHERE ID = 27
ROLLBACK
SELECT * FROM People

-- |||||||||||||||||||||||||||||||||||||||||||||||||        3        |||||||||||||||||||||||||||||||||||||||||||||||||

-- simulating rollback in catch block
select * from UserInfoTable

begin try
begin tran 
  update UserInfoTable
  set Salary -=100 where Id = 27
  
  update UserInfoTable
  set Salary -= 'a' where Id = 28
commit tran
	print 'tran commited'
end try 
begin catch 
	rollback
	print 'error found - rollbacked tran'
end catch 



-- |||||||||||||||||||||||||||||||||||||||||||||||||        4        |||||||||||||||||||||||||||||||||||||||||||||||||
-- for another transaction connection tests we are using: 00___test_querie file
-- and this is not just for transaction test but in general 

-- ISOLATION LEVEL EXAMPLES
-- READ UNCOMMITTED - dirty read side effect; 
-- READ COMMITTED / READ_COMMITTED_SNAPSHOT;
-- REPEATABLE READ - no other tran can delete or update the data before the initial tran commit; 
-- SNAPSHOT - same as SERIALIZABLE but does not aquire LOCKS - increased concurent tran with same data consistency; 
-- SERIALIZABLE - no other tran can delete, update or insert the data before the initial tran commit


-- dirty read happens when one transaction is permited to read data that has been modified by onother transaction ,
-- who is still not commited !!!
-- dirty read example - read wrong data from another connection if it is 'set transaction isolation level read uncommitted'
-- because by default it is : set to read_committed'


-- DIRTY READ : (the other connection is in 00_test_querie / -- 002 - DIRTY READ)
select @@trancount
set transaction isolation level read committed

select * from UserInfoTable where id = 27
select * from UserInfoTable(nolock) where id = 27

begin tran 
  update UserInfoTable
     set Salary =666 
   where Id = 27
  waitfor delay '00:00:15'
  print 'not enough money'
  rollback

   

-- LOST UPDATE (the other connection is in 00_test_querie / -- 003 - LOST UPDATE)
-- it is valid for read commited and uncommitted isolation levels, for other isolation levels we dont have this problem
-- it we change it to repeatable read the result will be different and will throw an error(deadlock error)
-- set transaction isolation level repeatable read


begin transaction
declare @salary_decrease int 

select @salary_decrease = ut.Salary 
  from UserInfoTable ut 
 where ut.Id = 27

waitfor delay '00:00:10'
select @salary_decrease -= 32

update UserInfoTable
set Salary = @salary_decrease 
where id = 27
print  @salary_decrease
commit tran

rollback

-- NON REPEATABLE READ (the other connection is in 00_test_querie / -- 004 - NON REPEATABLE READ)

select * from UserInfoTable

Begin Transaction
Select Salary 
  from UserInfoTable 
 where Id = 27

waitfor delay '00:00:10'

Select salary 
  from UserInfoTable 
 where Id = 27

Commit Transaction

rollback

-- PHANTOM READ (the other connection is in 00_test_querie / -- 005 - PHANTOM READ)

begin tran
select * 
  from UserInfoTable
  where id > 8210
  
  waitfor delay '00:00:10'

select * 
  from UserInfoTable
  where id > 8210

  commit 




-- SERIALIZABLE  isolation level (the other connection is in 00_test_querie / -- 006 - SERIALIZABLE )
-- 
set transaction isolation level serializable 

begin tran
update UserInfoTable
  set Salary += 4
  where Id = 27
  
  commit tran 

select * from UserInfoTable

rollback

-- SNAPSHOT isolation level (the other connection is in 00_test_querie / -- 007 - SNAPSHOT )

-- it does not use lock instead of versioning : it means we copy the last valid committed transaction and that is the result
-- we get when we execute snapshot isolation level
-- example : if the Salary is 200 in last committed tran , this is the value which we will see, even though we have another 
-- UNcommitted tran ! This is valid when we SELECT the data 
-- If we try to update it WILL be aborted if another transaction is running, because we risk to have lost update situation!
alter  database Userinfo
set allow_snapshot_isolation on 
set transaction isolation level snapshot

 begin tran
update UserInfoTable
  set Salary +=6
 where id = 27

 COMMIT TRAN
 rollback

 -- READ COMMITED SNAPSHOT is not a different isolation level it is just different way of implementing 
 -- READ COMMITTED isolation level and must be implemented by single connection !
-- id does not throw an error when we try to update, and also is statement level read consistency
 alter database UserInfo SET READ_COMMITTED_SNAPSHOT ON
 set transaction isolation level read committed
 begin tran
update UserInfoTable
  set Salary +=33
 where id = 27

 COMMIT TRAN
 rollback