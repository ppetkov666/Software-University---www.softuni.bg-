USE CoffeeDb
GO

/****** Object:  StoredProcedure [dbo].[spe_InsertData]    Script Date: 10/12/2018 16:36:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  OR ALTER PROCEDURE [dbo].[spe_InsertData] 
@first_name			NVARCHAR(50), 
@last_name			NVARCHAR(50),
@type_of_drink	NVARCHAR(50), 
@quantity				INT 
AS
BEGIN

DECLARE @drink_id INT SET @drink_id = 0 

SELECT @drink_id  = drink_id 
	FROM Drinks 
WHERE [drink_name] = @type_of_drink

DECLARE @user_id  INT SET @user_id = 0
 
 SELECT @user_id = [user_id] 
   FROM users
  WHERE first_name = @first_name 
    AND last_name  = @last_name

DECLARE @exist BIT  SET @exist = 0
 SELECT @exist = 1 
   FROM Quantities
  WHERE [drink_id] = @drink_id
    AND [user_id]  = @user_id


DECLARE @current_value  INT  SET @current_value = 0

SELECT @current_value = q.quantity 
  FROM Quantities q
 WHERE q.drink_id = @drink_id
   AND q.[user_id]  = @user_id



IF @exist = 1 BEGIN
 UPDATE Quantities
    SET quantity = @current_value + @quantity
  WHERE [drink_id] = @drink_id
    AND [user_id] = @user_id

 END ELSE BEGIN
  INSERT INTO Quantities
 VALUES
 (@drink_id,@user_id,@quantity)
	END
END
GO

exec [dbo].[spe_InsertData] 'Jeko','Minkov','coffee',1


select * from users
select * from Quantities




-- ---------------------------------------------------------------------------

GO

CREATE  OR ALTER PROCEDURE [dbo].[spe_insert_user_name] 
@first_name			NVARCHAR(50), 
@last_name			NVARCHAR(50)
AS
BEGIN

DECLARE @user_id  INT SET @user_id = 0
 
-- SELECT @user_id = [user_id] 
--   FROM users
--  WHERE first_name = @first_name 
--    AND last_name  = @last_name

DECLARE @exist BIT  SET @exist = 0
 SELECT @exist = 1 
   FROM Users
  WHERE first_name = @first_name
	  AND last_name  = @last_name
 -- AND [user_id]  = @user_id

IF @exist = 0 
	BEGIN
 INSERT INTO Users
 VALUES
 (@first_name,@last_name)
	END
END
GO

EXEC [dbo].[spe_insert_user_name] 'ivan','ivanov' 

SELECT * FROM Users
SELECT * FROM Quantities
SELECT * FROM Drinks
-- ---------------------------------------------------------




GO
CREATE  OR ALTER PROCEDURE [dbo].[spe_insert_drink] 
@drink_name			NVARCHAR(50), 
@price			    decimal(6,2)
AS
BEGIN
 
DECLARE @exist INT  SET @exist = 0
 SELECT @exist = 1 
   FROM Drinks
  WHERE drink_name = @drink_name
	  

 SELECT @exist = 2 
   FROM Drinks
  WHERE drink_name = @drink_name
	  AND price      = @price

IF @exist = 0  BEGIN
 INSERT INTO Drinks
 VALUES
(@drink_name,@price)
END

ELSE IF @exist = 1 BEGIN
 UPDATE Drinks
    SET price = @price
  WHERE drink_name = @drink_name
END;
END
GO

EXEC [dbo].[spe_insert_drink] 'fanta',0.90


SELECT * FROM Users
SELECT * FROM Quantities
SELECT * FROM Drinks






-- ----------------------------------------------------------
GO 
CREATE   PROCEDURE [dbo].[spe_get_users] 
AS
BEGIN
 SELECT * from Users
END
GO

-- ----------------------------------------------------------
GO 
CREATE   PROCEDURE [dbo].[spe_get_drinks] 
AS
BEGIN
 SELECT d.[drink_name] from Drinks d
END
GO

-- ------------------------------------------------------------

GO 
CREATE  or alter PROCEDURE [dbo].[spe_get_report] 
AS
BEGIN
 SELECT u.first_name as 'First name',
				 u.last_name as 'Last name',
			   d.drink_name as 'type of drink',
				 q.quantity,
				 d.price as 'Price in leva',
				 d.price * q.quantity 'total in leva'
	  FROM Quantities q
    JOIN Drinks d ON d.drink_id = q.drink_id
    JOIN Users u  ON u.[user_id] = q.[user_id]
ORDER BY u.first_name,d.drink_name DESC
END
GO

-- ----------------------------------------------------------------


GO 
CREATE  or alter PROCEDURE [dbo].[spe_get_custom_report] 
@first_name			NVARCHAR(50), 
@last_name			NVARCHAR(50)
AS
BEGIN
  SELECT u.first_name as 'First name',
				 u.last_name as 'Last name',
			   d.drink_name as 'type of drink',
				 q.quantity,
				 d.price as 'Price in leva',
				 d.price * q.quantity 'total'
	  FROM Quantities q
    JOIN Drinks d ON d.drink_id = q.drink_id
    JOIN Users u  ON u.[user_id] = q.[user_id]
	 WHERE u.first_name = @first_name 
	   AND u.last_name = @last_name
ORDER BY u.first_name,d.drink_name DESC
END
GO


exec [dbo].[spe_get_custom_report] 'jeko', 'minkov'


SELECT * FROM Users
SELECT * FROM Quantities
SELECT * FROM Drinks

