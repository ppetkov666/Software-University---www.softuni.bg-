

-- 001 - COALEASCE
-- 002 - ISNULL
-- 003 - LEAD and LAG
-- 004 - NTILE
-- 005 - FIRST_VALUE & LAST_VALUE
-- 006 - CHOOSE
-- 007 - IIF
-- 008 - TRY_PARSE, TRY_CONVERT
-- 009 - OFFSET + FETCH NEXT
-- 010 - QUOTENAME
-- 011 - IDENTITY
-- 012 - EXISTS
-- 013 - 
-- 014 - 
-- 015 - 
-- 016 - 
-- 017 - 

  -- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                               001 - COALEASCE
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  GO 
-- what it does : 
-- return the first value which is NOT NULL

-- ^^^^^^^^ example 1  ^^^^^^^^

  DECLARE @First      NVARCHAR(MAX) SET @First = NULL
  DECLARE @InBetween  NVARCHAR(MAX) 
  DECLARE @Second      NVARCHAR(MAX) SET @Second = 'SECOND'
  DECLARE @Third      NVARCHAR(MAX) SET @Third = 'THIRD' 

  SELECT COALESCE(@First,@InBetween,@Second,@Third)

-- ^^^^^^^^ example 2  ^^^^^^^^

  DECLARE @v_log_info                    NVARCHAR(2048);   SET @v_log_info = '';
  DECLARE @i_first_option_null_value    NVARCHAR(50)      SET @i_first_option_null_value = null;
  DECLARE @i_secon_option_empthy_string NVARCHAR(50)      SET @i_secon_option_empthy_string = '';

-- in first option on the table column the result will be "the result is <null>"
  SELECT @v_log_info = (COALESCE(@i_first_option_null_value,'<NULL>'))
  SELECT CONCAT('THE RESULT IS ', @v_log_info)
-- in second option on the table column the result will be "the result is "
  SELECT @v_log_info = (COALESCE(@i_secon_option_empthy_string,'<null>'))
  SELECT CONCAT('the result is ', @v_log_info)
-- that is the difference bettween null and string empthy 


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                         002 - ISNULL 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  USE SoftUni
  GO

-- ^^^^^^^^ example 1  ^^^^^^^^

-- simple sp  with optional param - if is null or 0 will give all record from the table otherwise it will give record according department id from test parm
  CREATE OR ALTER PROCEDURE sp_test
  (
    @test_param INT = 0
  )
  AS
  BEGIN
        SELECT e.FirstName,
               e.LastName 
          FROM Employees e
         WHERE (ISNULL(@test_param , 0) = 0  OR (e.DepartmentID = @test_param))
  END

  EXEC sp_test @test_param = 0

  SELECT e.FirstName,e.LastName 
    FROM Employees e 
   WHERE e.DepartmentID = '3'

  SELECT e.DepartmentID 
    FROM Employees e 
   WHERE e.FirstName = 'guy'


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                            003 - LEAD AND LAG
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO
USE SoftUni
GO

-- if the values of lead and lag functions return null we can either use their default value as parameter or isnull function as it is shown below
-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie returns empID, row number, firstname, lastname, salary, next row salary, and difference bettween last two column 
  SELECT e.EmployeeID,
         e.[row_number],
         e.FirstName, 
         e.LastName,
         e.Salary,
         e.previous_row_salary,
         e.next_row_salary,
         e.column_difference,
         lead_minus_lag
   FROM (SELECT emp.EmployeeID,
                ROW_NUMBER() OVER (ORDER BY emp.EmployeeID) [row_number],
                emp.FirstName,
                emp.LastName,
                emp.Salary,
                ISNULL(LAG(emp.Salary) OVER (ORDER BY emp.EmployeeID),0) AS previous_row_salary,
                ISNULL(LEAD(emp.Salary) OVER (ORDER BY emp.EmployeeID),0) AS next_row_salary,
                (emp.Salary - LEAD(emp.Salary) OVER (ORDER BY emp.EmployeeID)) column_difference,
                ((LEAD(emp.Salary,1,0) OVER (ORDER BY emp.EmployeeID)) - (LAG(emp.Salary,1,0) OVER (ORDER BY emp.EmployeeID))) lead_minus_lag
    FROM Employees emp) e
GO

-- ^^^^^^^^ example 2  ^^^^^^^^

-- this querie is simular to the first example BUT it is now quite correct because use employeeID number as reference and if a record it is deleted
-- then the result in next columns will be wrong , and actually it can be seen on the example
SELECT e.EmployeeID,
       e.[row_number],
       e.FirstName,
       e.LastName,
       e.Salary,
       e.next_salary,
       e.column_difference     
 FROM (SELECT emp.EmployeeID,
              ROW_NUMBER() OVER (ORDER BY EmployeeID) [row_number],
              emp.FirstName,
              emp.LastName,
              emp.Salary,
             (SELECT ie.Salary 
                FROM Employees ie 
               WHERE ie.EmployeeID = emp.EmployeeID + 1)               AS next_salary,
             (emp.Salary - (SELECT e1.Salary 
                              FROM Employees e1 
                             WHERE e1.EmployeeID = emp.EmployeeID + 1)) AS column_difference
         FROM Employees AS emp ) e  

-- ^^^^^^^^ example 3  ^^^^^^^^

-- this is the right way to be done unlike of example 2 
SELECT ctr.EmployeeID,
       ctr.row_num,
       ctr.FirstName,
       ctr.LastName,
       ctr.Salary,
       aNextSalary.Salary
 FROM (SELECT emp.EmployeeID,
              emp.FirstName,
              emp.LastName,
              emp.Salary,
              ROW_NUMBER() OVER (ORDER BY employeeID) row_num
         FROM Employees emp) AS ctr 
   INNER JOIN (SELECT e.Salary, 
                      e.row_num
                FROM (SELECT emp.Salary,
                             ROW_NUMBER() OVER (ORDER BY employeeID) row_num
                        FROM Employees emp) e ) aNextSalary ON aNextSalary.row_num =  ctr.row_num + 1


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    004 - NTILE() 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- ^^^^^^^^ example 1  ^^^^^^^^

-- this querie just create temp table with some data inside and split it per 2 groups
  CREATE TABLE  #temp
  (
    StudentID CHAR(2),    
    Marks      INT
  ) 
  INSERT #temp  VALUES('S1',75 ) 
  INSERT #temp  VALUES('S2',83)
  INSERT #temp  VALUES('S3',91)
  INSERT #temp  VALUES('S4',83)
  INSERT #temp  VALUES('S5',93 ) 


  SELECT NTILE(2) OVER(ORDER BY Marks),*
    FROM #temp
ORDER BY Marks

-- ^^^^^^^^ example 2  ^^^^^^^^

 -- split the data into 3 groups  and each group has unique number, and in this example the whole data is grouped or partitioned by salary
 -- it means each salary group is splitted by 3 
  SELECT e.FirstName,
         e.LastName,
         e.Salary,
         NTILE(3) OVER (PARTITION BY e.Salary ORDER BY e.salary) ntile_column       
         FROM Employees e

  -- ^^^^^^^^ example 3  ^^^^^^^^

-- this querie split the data into 3 groups and you can use each group as you like :
-- this querie  returns all the people from the first group 
SELECT  groups.* 
FROM (SELECT e.FirstName,
             e.LastName,
             e.Salary,
             NTILE(3) OVER ( ORDER BY e.EmployeeID) ntile_groups       
        FROM Employees e) groups
       WHERE groups.ntile_groups = 1


  -- ^^^^^^^^ example 4  ^^^^^^^^

  -- this querie returns all the people from the first group who has salary equal to 10000
  SELECT  groups.* 
    FROM ( SELECT e.FirstName,
                  e.LastName,
                  e.Salary,
                  NTILE(3) OVER (PARTITION BY e.Salary ORDER BY e.EmployeeID) ntile_groups       
             FROM Employees e
            WHERE e.Salary = 10000) groups
            WHERE groups.ntile_groups = 1

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                 005 - FIRST_VALUE() and LAST_VALUE()
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT e.FirstName,
       e.LastName,
       e.Salary,
       FIRST_VALUE(e.FirstName) over (partition by e.Salary order by e.salary) as first_value
  FROM Employees e
  order by e.Salary desc


  SELECT e.FirstName,
       e.LastName,
       e.Salary,
       LAST_VALUE(e.FirstName) over (partition by e.Salary order by e.salary) as first_value
  FROM Employees e
  order by e.Salary desc

  
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    006 - CHOOSE
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select e.FirstName, 
       e.LastName,
       e.hiredate,
       CHOOSE(DATEPART(MM,e.Hiredate), 'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec') [month]
 from Employees e

 select e.FirstName, 
       e.LastName,
       e.hiredate,
       convert(NVARCHAR(3),e.HireDate) [month]
 from Employees e


select e.FirstName,
       e.LastName,
       e.hiredate,
       case DATEPART(MM,e.Hiredate)
       when 1 then 'january'
       when 2 then 'february'
       when 3 then 'march'
       when 4 then 'april'
       when 5 then 'may'
       when 6 then 'june'
       when 7 then 'july'
       when 8 then 'august'
       when 9 then 'september'
       when 10 then 'october'
       when 11 then 'november'
       when 12 then 'december'
       end as [month]
  from Employees e

  select * from Employees

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                               007 - IIF
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- if is true: 'worker' if not: 'manager'

select e.FirstName,
       e.LastName,
       IIF(e.ManagerID is not null, 'worker', 'manager') as title
  from Employees e


select e.FirstName,
       e.LastName,
       case 
       when e.ManagerID is not null then 'worker'
       else 'manager'
       end as title
  from Employees e


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                               008 - TRY_PARSE, TRY_CONVERT        
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
select TRY_PARSE('petko' as int )

select  case 
        when TRY_PARSE('123' as int ) is null then 'conversion failed'
        else 'success'
        end 

select IIF(TRY_PARSE('123' as int ) is null, 'not parsed', 'parsed')
declare @v_test_1 int set @v_test_1 = 123123
declare @v_test int 
select @v_test = IIF(TRY_CONVERT(int, @v_test_1) is null, 0,@v_test_1)
print @v_test

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                               009 - OFFSET + FETCH NEXT
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
go
create or alter proc spe_offset_fetch_example_proc
(
@v_page_number int,
@v_page_size int
)
as
begin

  select * 
    from Employees e
    order by e.EmployeeID
  offset (@v_page_number - 1) * @v_page_size rows
  fetch next @v_page_size rows only

end

exec spe_offset_fetch_example_proc 2, 50

-- same proc but without  offset and fetch

go
create or alter proc spe_get_page_info
(
@page_number int,
@page_size int
)
as
begin
select e.FirstName,
       e.LastName,
       e.Salary,
       [row_number]
  from Employees e
  join (select e.EmployeeID, 
               ROW_NUMBER() over (order by e.EmployeeID) [row_number]
          from Employees e
      group by e.EmployeeID) as emp on emp.EmployeeID = e.EmployeeID 
         where row_number between ((@page_number - 1) * @page_size) and (@page_number * @page_size)
end


exec spe_get_page_info 2,50


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                   010 - QUOTENAME
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- as a second param it takes delimeter - only ONE
SELECT QUOTENAME('PETKO', '''''')
SELECT QUOTENAME('PETKO', '"')
SELECT QUOTENAME('PETKO', ']]]')
-- everything else than this delimeters will return NULL

SELECT QUOTENAME('PETKO', '?')
SELECT QUOTENAME('PETKO', '!')
SELECT QUOTENAME('PETKO', '***')

SELECT QUOTENAME('PETKO ] petkov')

declare @table_name nvarchar(100)
set @table_name = 'petko ] petkov'
select @table_name = QUOTENAME(@table_name)
print @table_name

-- 1 (object name) as second param
set @table_name = PARSENAME(@table_name, 1)
print @table_name





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    011 - IDENTITY     
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- to enable or disable insert value into identity column
SET IDENTITY_INSERT employees OFF -- or ON

-- to reset Identity column
DBCC CHECKIDENT(Employees, RESEED, 0)

select * from Employees
select SCOPE_IDENTITY()
select @@IDENTITY
select IDENT_CURRENT('employees')

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    012 - EXISTS     
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- The EXISTS operator returns true if the subquery returns one or more records.
  go
  CREATE OR ALTER PROCEDURE spe_test_proc
  AS
  BEGIN
    CREATE TABLE #temp_table_example ([name] NVARCHAR(50))
    INSERT INTO #temp_table_example 
    VALUES ('Petko')
  
    IF (OBJECT_ID('tempdb..#temp_table_example')) IS NOT NULL
      BEGIN
        SELECT 'Table exist' AS temp
        -- if NOT EXIST returns TRUE (which means that there is no record into #temp_table_example) then we get in IF statement
          IF ( NOT EXISTS  (SELECT 1 FROM #temp_table_example)) 
            BEGIN
              SELECT 'table is empthy!' AS temp
            END
          ELSE
            BEGIN
              SELECT * FROM #temp_table_example
            END
      END
    ELSE 
      BEGIN
        SELECT 'table does not exist!' AS temp
      END
  END

      exec spe_test_proc
      SELECT * FROM #temp_table_example

      