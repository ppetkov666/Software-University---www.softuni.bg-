SELECT 
db_name(rsc_dbid) AS 'DATABASE_NAME',
case rsc_type when 1 then 'null'
              when 2 then 'DATABASE' 
              WHEN 3 THEN 'FILE'
              WHEN 4 THEN 'INDEX'
              WHEN 5 THEN 'TABLE'
              WHEN 6 THEN 'PAGE'
              WHEN 7 THEN 'KEY'
              WHEN 8 THEN 'EXTEND'
              WHEN 9 THEN 'RID ( ROW ID)'
              WHEN 10 THEN 'APPLICATION' end  AS 'REQUEST_TYPE',

CASE req_ownertype WHEN 1 THEN 'TRANSACTION'
                   WHEN 2 THEN 'CURSOR'
                   WHEN 3 THEN 'SESSION'
                   WHEN 4 THEN 'ExSESSION' END AS 'REQUEST_OWNERTYPE',

OBJECT_NAME(rsc_objid ,rsc_dbid) AS 'OBJECT_NAME', 
PROCESS.HOSTNAME , 
PROCESS.program_name , 
PROCESS.nt_domain , 
PROCESS.nt_username , 
PROCESS.program_name ,
SQLTEXT.text 
FROM sys.syslockinfo LOCK JOIN 
     sys.sysprocesses PROCESS
  ON LOCK.req_spid = PROCESS.spid
CROSS APPLY sys.dm_exec_sql_text(PROCESS.SQL_HANDLE) SQLTEXT






begin transaction
	DECLARE @v_ug_id  int
	
	DECLARE cur cursor for
	select ug.Id
	from UsersGames ug
	 join Users u
	 on u.Id = ug.UserId
	 join Games g
	 on g.Id = ug.GameId
  where u.Username in ('buildingdeltoid', 'monoxidecos')
    and g.Name = 'Bali'
	
	OPEN cur
	FETCH NEXT FROM cur INTO @v_ug_id 

	WHILE @@FETCH_STATUS <> -1 BEGIN
	 update UsersGames
		set  Cash += 50000
	  where Id = @v_ug_id
		
	  FETCH NEXT FROM cur INTO @v_ug_id 
	END
	close cur
	deallocate cur

	commit transaction

	 
	SELECT 
db_name(rsc_dbid) AS 'DATABASE_NAME',
case rsc_type when 1 then 'null'
              when 2 then 'DATABASE' 
              WHEN 3 THEN 'FILE'
              WHEN 4 THEN 'INDEX'
              WHEN 5 THEN 'TABLE'
              WHEN 6 THEN 'PAGE'
              WHEN 7 THEN 'KEY'
              WHEN 8 THEN 'EXTEND'
              WHEN 9 THEN 'RID ( ROW ID)'
              WHEN 10 THEN 'APPLICATION' end  AS 'REQUEST_TYPE',

CASE req_ownertype WHEN 1 THEN 'TRANSACTION'
                   WHEN 2 THEN 'CURSOR'
                   WHEN 3 THEN 'SESSION'
                   WHEN 4 THEN 'ExSESSION' END AS 'REQUEST_OWNERTYPE',

OBJECT_NAME(rsc_objid ,rsc_dbid) AS 'OBJECT_NAME', 
PROCESS.HOSTNAME , 
PROCESS.program_name , 
PROCESS.nt_domain , 
PROCESS.nt_username , 
PROCESS.program_name ,
SQLTEXT.text 
FROM sys.syslockinfo LOCK JOIN 
     sys.sysprocesses PROCESS
  ON LOCK.req_spid = PROCESS.spid
CROSS APPLY sys.dm_exec_sql_text(PROCESS.SQL_HANDLE) SQLTEXT

	begin transaction
update UsersGames
  set  Cash += 50000
  where UserId in (select u.Id from Users u where u.Username in ('buildingdeltoid', 'monoxidecos'))
    and GameId = (select g.Id from Games g where g.Name = 'Bali')

	commit transaction