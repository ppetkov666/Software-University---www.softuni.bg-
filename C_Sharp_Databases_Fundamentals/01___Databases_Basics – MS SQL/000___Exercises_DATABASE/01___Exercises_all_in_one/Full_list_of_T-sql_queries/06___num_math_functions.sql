


-- 001 - ROWCOUNT
-- 002 - FLOOR, ROUND, SQUARE, POWER, ABS,

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                    001 - @@ROWCOUNT
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  GO
-- what it does : 
-- it shows the count of the rows 
  SELECT e.* 
    FROM Employees e 
   WHERE e.FirstName like 'p%'
  SELECT @@ROWCOUNT

  SELECT TOP 2 * 
    FROM Employees e 
   WHERE e.FirstName like 'p%'
  SELECT @@ROWCOUNT

  SELECT TOP 1 * 
    FROM Employees e 
   WHERE e.FirstName like 'p%'
  SELECT @@ROWCOUNT

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                   002 - FLOOR, ROUND, SQUARE, POWER, ABS,                 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- all math functions can be found at : Programmability/System Functions/Mathematical Functions

-- random between 0 and 100(by default if there is no seed as param numbers will be between 0 and 1 )
SELECT FLOOR(RAND()*100)

SELECT ROUND(666.21,2) --666.670
-- the third param is either 0 or 1 or 99 just indicate whether to round it or truncate it
SELECT ROUND(666.666,2,1) --666.660 JUST TRUNCATE THE RESULT(ignore the result after the second digit)
SELECT ROUND(666.666,-2) -- 700.000 
SELECT ROUND(666,2,1)


GO
DECLARE @counter int 
SET @counter = 1
WHILE(@counter <= 10)
BEGIN
  PRINT floor(rand() * 100)
   SELECT @counter +=1
END

SELECT LOG(8,2)
SELECT SQUARE(9)
SELECT POWER(9,2)
SELECT ABS(-15.2)
SELECT CEILING(8.2)
SELECT FLOOR(8.2)











































































