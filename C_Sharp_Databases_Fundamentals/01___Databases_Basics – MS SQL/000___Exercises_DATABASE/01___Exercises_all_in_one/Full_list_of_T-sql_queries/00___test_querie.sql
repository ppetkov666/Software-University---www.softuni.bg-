
-- 001 - TEST QUERIE FOR TRANSACTION TO SIMULATE DEADLOCK
-- 002 - DIRTY READ
-- 003 - LOST UPDATE
-- 004 - NON REPEATABLE READ 
-- 005 - PHANTOM READ
-- 006 - SERIALIZABLE
-- 007 - SNAPSHOT













-- |||||||||||||||||||||||||||||||||||||||||||||||||        001        |||||||||||||||||||||||||||||||||||||||||||||||||

-- 

-- trace flag 1222
dbcc traceon(1222, -1)

-- status of the trace flag
dbcc Tracestatus(1222, -1)

dbcc traceoff(1222, -1)

execute sp_readerrorlog

select * from People
select * from UserInfoTable

select OBJECT_NAME([OBJECT_ID])
  from sys.partitions
 where hobt_id = 72057594043105280


set deadlock_priority NORMAL
go
CREATE OR ALTER PROCEDURE sp_tran_two
AS
BEGIN
  BEGIN TRANSACTION
  BEGIN TRY 
  UPDATE People
     SET Firstname = 'testname' + ' transaction 2'
   WHERE id = 2
  
  WAITFOR DELAY '00:00:15'
  
  UPDATE UserInfoTable 
     SET FirstName = 'testname' + ' transaction 2'
   WHERE id = 27 
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
rollback
exec sp_tran_two
-- -----------------------------------------------
-- trying to access from this connection  the same table which is already being executed in transaction 
-- with update statement from another connection : 08___stor_proc_trig_func / 005 - TRANSACTIONS / 1
SELECT * FROM UserInfoTable WHERE ID = 27 -- option one - this is statement executed from other connection with transaction
SELECT * FROM UserInfoTable WHERE ID = 28 -- option two 
SELECT * FROM UserInfoTable -- option three


BEGIN TRANSACTION
select * from UserInfoTable ut where id = 27
rollback
UPDATE UserInfoTable
SET Salary = 6666666 WHERE ID = 27


-- |||||||||||||||||||||||||||||||||||||||||||||||||        002        |||||||||||||||||||||||||||||||||||||||||||||||||
-- DIRTY READ

set transaction isolation level read committed
-- 
set transaction isolation level read uncommitted
select * from UserInfoTable(nolock) where id = 27  -- when we want to read during execution of another tran

select @@trancount
begin tran
select * from UserInfoTable where id = 27

-- |||||||||||||||||||||||||||||||||||||||||||||||||        003        |||||||||||||||||||||||||||||||||||||||||||||||||

-- LOST UPDATE 
-- set transaction isolation level repeatable read


begin transaction
declare @salary_decrease int 

select @salary_decrease = ut.Salary 
  from UserInfoTable ut 
 where ut.Id = 27

waitfor delay '00:00:1'
select @salary_decrease -= 20

update UserInfoTable
set Salary = @salary_decrease 
where id = 27
print  @salary_decrease
commit tran

rollback


-- |||||||||||||||||||||||||||||||||||||||||||||||||        004        |||||||||||||||||||||||||||||||||||||||||||||||||
-- NON REPEATABLE READ 
-- set transaction isolation level read committed
select * from UserInfoTable
-- Transaction 2
begin tran
Update UserInfoTable 
   set Salary = 666 
 where Id = 27


 -- |||||||||||||||||||||||||||||||||||||||||||||||||        005        |||||||||||||||||||||||||||||||||||||||||||||||||
 -- PHANTOM READ 

 insert into UserInfoTable
 values
 ('phantom next','read',555)

 -- |||||||||||||||||||||||||||||||||||||||||||||||||        006        |||||||||||||||||||||||||||||||||||||||||||||||||
 
 -- - SERIALIZABLE  isolation level

 set transaction isolation level serializable   

begin tran
select Salary 
  from UserInfoTable 
 where id = 27

  rollback

 -- |||||||||||||||||||||||||||||||||||||||||||||||||        007        |||||||||||||||||||||||||||||||||||||||||||||||||
-- SNAPSHOT  isolation level / -- READ COMMITED SNAPSHOT isolation level
-- with SELECT we get last committed value, with UPDATE throw an error to avoid LOST UPDATE problem,
-- and this is valid for DELETE and INSERT also 
--alter database UserInfo 
--SET ALLOW_SNAPSHOT_ISOLATION ON

set transaction isolation level snapshot
select * from UserInfoTable
 begin tran
 --SELECT * FROM UserInfoTable WHERE ID = 27
update UserInfoTable
  set Salary +=66 
 where id = 27

  commit tran

  rollback
  select * from UserInfoTable where id = 27
  begin tran
  select * from UserInfoTable(nolock) where id = 27
  select @@trancount

-- READ COMMITED SNAPSHOT isolation level 

  begin tran
 SELECT * FROM UserInfoTable WHERE ID = 27
--update UserInfoTable
--  set Salary +=66 
-- where id = 27
SELECT * FROM UserInfoTable WHERE ID = 27
  commit tran

  rollback























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