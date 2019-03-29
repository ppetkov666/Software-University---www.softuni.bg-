
USE MyDataBaseSample
SELECT * FROM UserInfo
insert into UserInfo
values
('testUser',1111111111,'this is sampleemaile@gooooooooooogle.com','test streeeet','testcity')

GO
CREATE OR ALTER PROCEDURE sp__search_users
(
@user_name NVARCHAR(50) = NULL,
@email VARCHAR(50) = NULL,
@town VARCHAR(50) = NULL
)
AS
BEGIN
  SELECT * 
    FROM UserInfo ui
   WHERE (ui.UserName = @user_name or @user_name IS NULL) AND
         (ui.Email    = @email  OR @email IS NULL)        AND
         (ui.Town      = @town OR @town IS NULL)
END

EXECUTE sp__search_users @user_name = 'FirstUser' 
ALTER TABLE UserInfo 
ADD UniqueNumber int


UPDATE UserInfo
SET UniqueNumber = 6
WHERE Id = 6  

-- --------------------------------------------------------------------------------------------------------

use Joins_Test_DB
SELECT * FROM department
SELECT * FROM users

-- ----------------------------------------------------------------------------------------------------------
go

create database web_Demo_db
use web_Demo_db

CREATE TABLE Cars(
Id INT PRIMARY KEY IDENTITY,
Make NVARCHAR(50),
Model NVARCHAR(50),
[Year] INT,
AdditionalInformation NVARCHAR(50),
)
select * from Cars

-- ----------------------------------------------------------
use PeopleDataBase
select * from People
-- -----------------------------------------------------
drinks , users and quantities
create database CoffeeDb
use CoffeeDb
Create Table Drinks(
Id int primary key Identity,
Name nvarchar(50) not null,
 nvarchar(50) not null,
UserId nvarchar(50) not null
)