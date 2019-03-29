

-- this querie consist the following :
-- SUBSTRING
-- LTRIM, RTRIM, ASCII, CHAR, LOWER, UPPER
-- CHARINDEX, LEFT, RIGHT, SUBSTRING
-- REPLICATE, CONCAT+SPACE, PATHINDEX, REPLACE, STUFF




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                                  SUBSTRING
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  GO
 -- what it does : 
 -- in the following examples extract 4096 characters as starting from 1 
 -- using coalesce it says if the variable inside is null it will return the string inside bettween quotes which is 'NULL',IF NOT  it will return the actuall value
 -- of the variable because that is what COALESCE does  - return the first value different than NULL

 -- ^^^^^^^^ example 1  ^^^^^^^^

  DECLARE @v_log_info        NVARCHAR(2048); SET @v_log_info = '';
  DECLARE @i_location_code  NVARCHAR(10)    SET @i_location_code = NULL
  DECLARE @i_warehouse_code NVARCHAR(10)    SET @i_warehouse_code = '34RREWR'

  SELECT @v_log_info = SUBSTRING(
  'Procedure bmever.spe__GetContainerCount <'   
  + '@i_location_code = '    +  '''' + COALESCE(@i_location_code,'NULL')  + ''''
  + ', @i_warehouse_code = ' +  '''' + COALESCE(@i_warehouse_code,'NULL') + ''''
  + '>', 1, 4096);
  PRINT @v_log_info

  GO

-- ^^^^^^^^ example 2  ^^^^^^^^

  DECLARE @v_log_info              NVARCHAR(2048); SET @v_log_info = '';
  DECLARE @i_creation_dt          DATETIME ;      SET @i_creation_dt = '2017-06-14 09:13:02.150';
  DECLARE @i_completion_dt        DATETIME ;      SET @i_completion_dt = '2017-06-14 09:15:56.490'
  DECLARE @i_handling_user_code   NVARCHAR(30)    SET @i_handling_user_code = 'JDO'
  DECLARE @i_task_status          SMALLINT        SET @i_task_status = 80

  SELECT @v_log_info = SUBSTRING(
  'Procedure spr__printing_report_data <'   
  + '@i_creation_dt = '                  +    COALESCE(CAST(@i_creation_dt   AS NVARCHAR(50)),'NULL')
  + ', @i_completion_dt = '             +    COALESCE(CAST(@i_completion_dt AS NVARCHAR(50)),'NULL')
  + ', @i_handling_user_code = ' + '''' +   COALESCE(@i_handling_user_code, 'NULL') + ''''
  + ', @i_task_status = '                +    COALESCE(CAST(@i_task_status   AS NVARCHAR(20)),'NULL')
  + '>', 1, 4096);

  PRINT @v_log_info

-- ^^^^^^^^ example 3  ^^^^^^^^

-- this is just to demonstrate how to escape single quotes
  GO

  DECLARE @test_print NVARCHAR(2048);    SET @test_print = '';
  DECLARE @test_var  NVARCHAR(30)        SET @test_var = 'first_print_message'

  SELECT @test_print = SUBSTRING('this is test print :<' + '@test_var = ' + '   ''   ' + COALESCE(@test_var,'null') + '''',1,300)
  PRINT @test_print

-- ^^^^^^^^ example 4  ^^^^^^^^

  GO
  DECLARE @v_log_info          NVARCHAR(2048);     SET @v_log_info = '';
  DECLARE @i_first_number      INT                  SET @i_first_number = 50
  DECLARE @i_second_number    INT                  SET @i_second_number = 60
  DECLARE @o_sum_two_numbers  INT                  SET @o_sum_two_numbers = @i_first_number +@i_second_number
  DECLARE @i_final_message    NVARCHAR(50)        SET @i_final_message = 'FINAL'

  SELECT @v_log_info = REPLACE(
  'Procedure bmever.cap__get_sum_of_two_numbers' 
  + ' <@i_first_number = '            +  RTRIM(COALESCE(CAST(@i_first_number      AS NVARCHAR(20)), '<null>')) 
  + ', @i_second_number = '            +  RTRIM(COALESCE(CAST(@i_second_number    AS NVARCHAR(20)), '<null>')) 
  + ', @o_sum_two_numbers = '          +  RTRIM(COALESCE(CAST(@o_sum_two_numbers  AS NVARCHAR(20)), '<null>')) 
  + ', @i_final_message = '   + ''''  + RTRIM(COALESCE(@i_final_message, '<null>')) + '''' +
  '>', '''<null>''', 'NULL');
  PRINT @v_log_info

  GO

-- ^^^^^^^^ example 5  ^^^^^^^^

  DECLARE @v_log_info          NVARCHAR(2048);     SET @v_log_info = '';
  DECLARE @i_first_number      INT                  SET @i_first_number = 50
  DECLARE @i_second_number    INT                  SET @i_second_number = 60
  DECLARE @o_sum_two_numbers  INT                  SET @o_sum_two_numbers = @i_first_number +@i_second_number


  SELECT @v_log_info = SUBSTRING(
  'Procedure spe__get_container_count <'   
  + '@i_first_number = '      + COALESCE(CAST(@i_first_number    AS NVARCHAR(20)),'NULL')
  + ', @i_second_number = '    + COALESCE(CAST(@i_second_number   AS NVARCHAR(20)),'NULL')
  + ', @o_sum_two_numbers = ' + COALESCE(CAST(@o_sum_two_numbers AS NVARCHAR(20)),'NULL')
  + '>', 1, 4096);
  PRINT @v_log_info
  GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                  TRIM LTRIM, RTRIM, ASCII, CHAR, LOWER, UPPER                                
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT ASCII('a')
SELECT CHAR(97)

-- print alphabet english 
DECLARE @start INT SET @start = 65
WHILE(@start <= 90)
BEGIN
  PRINT CHAR(@start)
  SET @start = @start + 1
END
GO
-- print numbers 0 to 9
DECLARE @start INT SET @start = 48
WHILE(@start <= 57)
BEGIN
  PRINT CHAR(@start)
  SET @start +=1 
END

GO

DECLARE @first_name NVARCHAR(200) SET @first_name = '     petko                 ';
DECLARE @last_name NVARCHAR(200)  SET @last_name = '                                 PETKOV     ';
SELECT  LTRIM(upper(RTRIM(@first_name)) + ' ' + LOWER(LTRIM(@last_name))) AS full_name

DECLARE @first_name NVARCHAR(200) SET @first_name = '     petko                 ';
SELECT TRIM(@first_name) + ' ' + 'PETKOV'


SELECT e.FirstName, 
       LEN(e.FirstName) length_of_the_first_name 
  FROM Employees e


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                            CHARINDEX, LEFT, RIGHT, SUBSTRING                      
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


SELECT e.FirstName,
       LEFT(lower(e.FirstName),1) first_letter, 
       RIGHT(e.FirstName,1) first_letter 
  FROM Employees e


DECLARE @email NVARCHAR(200)   SET @email = 'petko123@abv.bg'
DECLARE @rest INT SET @rest = len(@email) - CHARINDEX('@',@email,1)

SELECT SUBSTRING(@email,CHARINDEX('@',@email,1) + 1,@rest) AS domain

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                        REPLICATE, CONCAT+SPACE, PATHINDEX, REPLACE, STUFF    
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- how to mask a year from hire date
SELECT e.FirstName,
       e.LastName,
       REPLICATE('*',4) +  SUBSTRING(CAST(CAST(e.HireDate AS DATE) AS NVARCHAR ),6,5)  day_month
  FROM Employees e

-- how to use space function and concat
SELECT e.FirstName,
       e.LastName,
       CONCAT(e.FirstName,SPACE(10),e.lastname)
  FROM Employees e

-- how to use pathindex

SELECT e.FirstName,
       e.LastName,
       e.JobTitle,
       PATINDEX('%Technician',e.JobTitle) Technician_index
  FROM Employees e
  WHERE PATINDEX('%Technician',e.JobTitle) > 0

-- replace usage

SELECT e.FirstName,
       e.LastName,
       e.JobTitle,
       REPLACE(e.JobTitle,'Technician','co-tech-support') changed_title_technician
  FROM Employees e

-- stuff
SELECT e.FirstName,
       e.LastName,
       e.JobTitle,
       cast(e.HireDate as nvarchar) hire_date,
       stuff(cast(e.HireDate as nvarchar),1,3,'*****') masked_hire_date 
  FROM Employees e
WHERE  E.JobTitle = 'Production Technician'

























