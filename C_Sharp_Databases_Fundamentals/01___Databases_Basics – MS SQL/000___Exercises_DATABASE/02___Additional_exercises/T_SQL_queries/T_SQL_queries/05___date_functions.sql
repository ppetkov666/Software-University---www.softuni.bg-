

-- this querie consist the following :
-- GETDATE(), CURRENT_TIMESTAMP, SYSDATETIME(), SYSDATETIMEOFFSET(), GETUTCDATE() 
-- DATENAME(),ISDATE()
-- DATEPART, DATEDIFF, CALCULATE PERSON AGE example
-- CAST, CONVERT


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                         GETDATE(), CURRENT_TIMESTAMP, SYSDATETIME(), SYSDATETIMEOFFSET(), GETUTCDATE()                                                                                 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT GETDATE()
SELECT CURRENT_TIMESTAMP
SELECT SYSDATETIME()
SELECT SYSDATETIMEOFFSET()
SELECT GETUTCDATE()


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                             DATENAME(), ISDATE()                       
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 SELECT e.FirstName,
        e.HireDate,
        DAY(e.HireDate) day,
        DATENAME(DAYOFYEAR,e.HireDate) day_of_the_year,
        DATENAME(WEEKDAY,e.HireDate) day_of_the_week,
        MONTH(e.HireDate) month,
        DATENAME(MONTH,e.HireDate) month_as_name,
        YEAR(e.HireDate) year,
        ISDATE(e.HireDate) hire_date_yes_or_no,
        ISDATE(e.FirstName) first_name 
   FROM Employees e


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                               DATEPART, DATEDIFF, CALCULATE PERSON AGE                    
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT e.FirstName,
        e.HireDate,
        DATENAME(WEEKDAY,e.HireDate) day_of_the_week,
        DATEPART(WEEKDAY,E.HireDate) day_as_number,
        DATEADD(day,20,e.HireDate) added_days,
        DATEDIFF(year,e.HireDate,GETDATE()) years_at_the_company
   FROM Employees e

-- how to calculate age of a person
-- this example below show why we have this case statements into the sp
SELECT DATEDIFF(YEAR, '11/30/2005','01/31/2006')
GO
CREATE OR ALTER PROCEDURE spe_calculate_person_age
(
@date_of_birth DATETIME,
@detailed_info_person_age nvarchar(100) output 
)
as
begin

DECLARE @dob DATETIME   SET @dob = @date_of_birth
DECLARE @temp_date DATETIME
DECLARE @years INT
DECLARE @months INT
DECLARE @days INT

SELECT @temp_date = @dob

SELECT @years = DATEDIFF(YEAR, @temp_date,GETDATE()) - 
                CASE 
                  WHEN (MONTH(@dob) > MONTH(GETDATE())) OR
                       (MONTH(@dob) = MONTH(GETDATE())) AND (DAY(@dob) > DAY(GETDATE()))
                  THEN 1 ELSE 0
                END
SELECT @temp_date = DATEADD(YEAR,@years,@temp_date)
--19 november 2018
SELECT @months = DATEDIFF(MONTH, @temp_date,GETDATE()) - 
                CASE 
                  WHEN (DAY(@dob) > DAY(GETDATE()))
                  THEN 1 ELSE 0
                END


SELECT @temp_date = DATEADD(MONTH,@months,@temp_date)
-- 19 december 2018
SELECT @days = DATEDIFF(DAY, @temp_date,GETDATE())

--select @years as years , @months as month, @days as day
 set @detailed_info_person_age = 'this person is: ' + cast(@years as nvarchar) + ' years ' + cast(@months as nvarchar) + ' month and ' + cast(@days as nvarchar) + ' days old !'
end

declare @person_age nvarchar(100)
exec spe_calculate_person_age @date_of_birth = '12/04/1992',@detailed_info_person_age = @person_age output 
print @person_age



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                       CAST, CONVERT          
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- the slight different between both is that cast is based on ansi standart and is better to be used unless we need extra style functionality wich convert give us!
-- just a hint - whatever is in this type of brackets [] is optional parameter according to msdn documentation
SELECT e.FirstName,
       e.LastName,
       SUBSTRING(CAST(e.HireDate as nvarchar),1,12) cast_and_substring, 
       cast(e.HireDate as date)using_just_date_function,
       cast(e.HireDate as nvarchar(12)) cast_with_lenght_param,  
       convert(NVARCHAR(3),e.HireDate) convert_with_lenght_param,
       convert(NVARCHAR(12),e.HireDate,101) convert_with_style_param_101,
       convert(NVARCHAR(12),e.HireDate,102) convert_with_style_param_102,
       convert(NVARCHAR(12),e.HireDate,103) convert_with_style_param_103,
       convert(NVARCHAR(12),e.HireDate,104) convert_with_style_param_104,
       convert(NVARCHAR(12),e.HireDate,105) convert_with_style_param_105
  FROM Employees e

SELECT e.FirstName,
       e.LastName,
       e.FirstName + ' ' + e.LastName + ' with id: ' + cast(e.EmployeeID AS NVARCHAR)
  FROM Employees e

  -- if i dont cast it to DATE we will have different result because the time will be included 
  SELECT CAST(e.HireDate AS DATE), COUNT(e.EmployeeID) count_of_people_per_hire_date
    FROM Employees e
GROUP BY CAST(e.HireDate AS DATE)





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                                   
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////












-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                                   
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////











-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                                   
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////












-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                                   
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



























