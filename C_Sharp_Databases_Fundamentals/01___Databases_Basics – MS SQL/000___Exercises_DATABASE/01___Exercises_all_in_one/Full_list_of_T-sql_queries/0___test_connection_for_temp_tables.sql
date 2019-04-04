CREATE TABLE #PersonDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO #PersonDetails
VALUES
('x'),
('y'),
('z')

select * from #PersonDetails
SELECT [NAME] FROM tempdb..sysobjects
WHERE NAME LIKE '%#PersonDetails%'

-- Global temp tables are accesible  because they are visible from all the connections
select * from ##EmployeeDetails

-- that's why i cannot create a table with the same name from this connection 
CREATE TABLE ##EmployeeDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO ##EmployeeDetails
VALUES
('x'),
('y'),
('z')

SELECT * FROM ##EmployeeDetails

-- TEST QUERIE FOR TRANSACTION TO SIMULATE DEADLOCK
-- -----------------------------------------------------------
begin transaction
update People
set Firstname = 'testname'
where id = 2

rollback


begin transaction

update UserInfoTable 
SET FirstName = 'testname' 
where id = 27 



-- -----------------------------------------------
-- trying to access from this connection  the same table which is already being executed in transaction with update statement from another connection
SELECT * FROM UserInfoTable WHERE ID = 27 -- option one - this is statement executed from other connection with transaction
SELECT * FROM UserInfoTable WHERE ID = 28 -- option two 
SELECT * FROM UserInfoTable -- option three



BEGIN TRANSACTION
UPDATE UserInfoTable
SET Salary = 6666666 WHERE ID = 27






