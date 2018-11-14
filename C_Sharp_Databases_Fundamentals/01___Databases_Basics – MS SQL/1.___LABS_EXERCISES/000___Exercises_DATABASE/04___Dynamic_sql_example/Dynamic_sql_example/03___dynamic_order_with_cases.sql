
CREATE TABLE UserInfoTable(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Salary INT
)
INSERT INTO UserInfoTable
VALUES 
('PETKO','ATANASOV',500),
('IVAN','IVANOV',100),
('GEORGI','GEORGIEV',300),
('KALOYAN','IVANOV',NULL),
('PETKO','PETKOV',600),
('IVAN','IVANOV',200),
('PETKO','PETKOV',500)
			 
-- --------------------------------------------- couple different approaches how to use dynamic order with CASE statement
USE UserInfo


 -- FIRST ONE  ---------------------------------------------------


GO
CREATE OR ALTER PROCEDURE get_ordered_data_v_1
(
@i_first_name bit = 0,
@i_last_name bit = 0,
@i_salary bit = 0
)
AS
BEGIN

  SELECT e.*
    FROM UserInfoTable e
ORDER BY 
    CASE WHEN @i_first_name = 1 and @i_last_name = 1 and @i_salary =  1 THEN CONVERT(char(10), e.FirstName) + CONVERT(char(10), ISNULL(e.Salary,'')) END,
	CASE WHEN @i_first_name = 1 and @i_last_name = 1                    THEN  CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) END,
    CASE WHEN @i_salary = 1                                             THEN  e.Salary
     END 
  END
GO

 exec get_ordered_data_v_1 @i_first_name = 0, @i_last_name = 0, @i_salary = 1


-- SECOND ONE  ---------------------------------------------------


GO
CREATE OR ALTER PROCEDURE get_ordered_data_v_2
(
@i_first_name bit = 0,
@i_last_name bit = 0,
@i_salary bit = 0
)
AS
BEGIN

  SELECT e.*,
	CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName),CONVERT(char(10), ISNULL(e.Salary,'')) as A1,
	CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) as A2
    FROM UserInfoTable e
ORDER BY 
    CASE WHEN @i_first_name = 1 and @i_last_name = 1 and @i_salary = 1 THEN CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) + CONVERT(char(10), ISNULL(e.Salary,''))
		 WHEN @i_first_name = 1 and @i_last_name = 1                   THEN CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName)
         WHEN @i_salary = 1                                            THEN  e.Salary
     END 
  END
GO

EXEC get_ordered_data_v_2 @i_first_name = 0, @i_last_name = 0, @i_salary = 1


-- THIRD ONE ---------------------------------------------------

GO

CREATE or alter PROCEDURE get_ordered_data_v_3 ( @ColumnName varchar(max) ) AS
BEGIN
SELECT e.*,
CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) + CONVERT(char(10), ISNULL(e.Salary,'')) as A1,
CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) AS A2
FROM UserInfoTable e
ORDER BY
    CASE when @ColumnName = 'fls' THEN CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName) + CONVERT(char(10), ISNULL(e.Salary,''))
	     when @ColumnName = 'fl'  THEN CONVERT(char(10), e.FirstName) + CONVERT(char(10), e.LastName)
	     when @ColumnName = 's'   THEN CONVERT(char(10), ISNULL(e.Salary,''))
     END 
END
GO

	EXEC get_ordered_data_v_3 @ColumnName = 's'

	
-- FOURTH ONE  ---------------------------------------------------


GO 

CREATE or alter PROCEDURE get_ordered_data_v_4 ( @ColumnName varchar(max) ) AS
BEGIN
  SELECT e.*
    FROM UserInfoTable e
ORDER BY
	CASE WHEN @ColumnName = 'fls' THEN e.FirstName END,
	CASE WHEN @ColumnName = 'fls' THEN e.LastName END, 
	CASE WHEN @ColumnName = 'fls' THEN e.Salary END, 
	CASE WHEN @ColumnName = 'fl' THEN e.FirstName END,
	CASE WHEN @ColumnName = 'fl' THEN e.LastName END, 
	CASE WHEN @ColumnName = 'lf' THEN e.Salary     
   END 
END
GO
	EXEC get_ordered_data_v_4 @ColumnName = 'fls'