
 
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         001 
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 DECLARE @last_name              NVARCHAR (MAX);          SET @last_name = null;
 declare @salary			           INT			                SET @salary = 0;
 DECLARE @customselect           NVARCHAR(max)
     SET @customselect = '
  SELECT * 
    FROM UserInfoTable uit
  WHERE (' + '''' + ISNULL(@last_name , '') + '''' + ' = '''' OR uit.LastName = ' + '''' + ISNULL(@last_name,'') + '''' + ') 
    AND (' + ISNULL(cast(@salary as nvarchar(50)), 0) + ' = 0 OR uit.Salary = ' + ISNULL(cast(@salary as nvarchar(50)),0) + ')
  order by uit.LastName'
   
  print @customselect
  exec SP_EXECUTESQL @customselect
  select * from UserInfoTable

 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         002 
 -- -------------------------------------------------------------------------------------------------------------------------------------------
  GO
 select * 
   from UserInfoTable 
  where Salary is null 

 go
 declare @salary			     INT			 SET @salary = 0;
 select * 
   from UserInfoTable 
  where @salary is null

 go
 declare @salary			     INT			 SET @salary = 0;
 select * 
   from UserInfoTable 
  where ISNULL(@salary, 0) = 0


 go
 DECLARE @last_name              NVARCHAR (MAX);    SET @last_name = 'PETKOV';
 
  SELECT * 
    FROM UserInfoTable uit
  WHERE (@last_name IS NULL OR @last_name = '' OR uit.LastName = @last_name ) 
  
  GO

  DECLARE @last_name              NVARCHAR (MAX);    SET @last_name = '';
  SELECT * 
    FROM UserInfoTable uit  
   WHERE (isnull(@last_name,'') = '' or uit.LastName = @last_name)
 
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         003 
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 

declare @params nvarchar(max)
declare @dynamic_querie nvarchar(max)

-- it is a bad practice to concatenate strings !!! there is vulnerability to sql injection
set @params = '@first_name nvarchar(100), @last_name nvarchar(100)'
set @dynamic_querie = 'select * from Employees' + ' where FirstName=@first_name and LastName=@last_name'

exec sp_executesql @dynamic_querie, @params, @first_name = 'guy', @last_name = 'gilbert'


-- example for sql injection 
exec spSearchEmployeesBadDynamicSql @i_first_name = ''update Employees set Salary = 13000 where FirstName = 'guy' and LastName = 'gilbert' --'


select * from Employees


-- comparing  both ways to execute dynamic sql -------------------------------------------------------------
-- sql server has auto parameterisation feature and with Quotename we can avoid sql injection but it is better 
-- to use sp_executesql over exec()


declare @test_fn nvarchar(50)
set @test_fn = '''drop database Employees -- '''
--set @test_fn = 'roberto'
declare @sql nvarchar(max)
set @sql = 'select * from Employees where FirstName = ' + QUOTENAME(@test_fn, '''')
print @sql
execute (@sql)


 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         004
 -- -------------------------------------------------------------------------------------------------------------------------------------------

 go
 -- this option does not work in sql server 
 create or alter proc spe_dynamic_sql_proc_v1 
(
 @i_table_name nvarchar(100)
)
 as
 begin
    
    declare @sql nvarchar(max)
        set @sql = 'select * from @searched_table'
    execute sp_executesql @sql,N'@searched_table nvarchar(50)', @searched_table = @i_table_name
 end

 exec spe_dynamic_sql_proc_v1 Employees
 
 
-- this is the way this procedure works - without Quotename we are susceptable to sql injection
 go
create or alter proc spe_dynamic_sql_proc 
(
 @test nvarchar(100)
)
 as
 begin
    declare @sql nvarchar(max)
    set @sql = 'select * from ' + QUOTENAME(@test)  -- + @test 
    PRINT @SQL
    execute sp_executesql @sql 
 end

 exec spe_dynamic_sql_proc employees


 select QUOTENAME('petko petkov','''')
 select QUOTENAME('petko petkov','"')



  -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         005
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 -- dynamic output param in SP

 declare @sql_ nvarchar(max) 
 declare @salary_i int set @salary_i = 100000;  

 set @sql_ = 'select * from Employees where Salary > @salary'

 execute sp_executesql @sql_, N'@salary int', @salary = @salary_i

 go

 create or alter proc spe_dynamic_count
 (
 @salary_i int,
 @count int output
 )
 as
 begin
  declare @sql_v1 nvarchar(max)   
  set @sql_v1 = 'select @count = count(*) from Employees where Salary > @salary'

  -- first param : @sql stament 
  -- second param: the variables and their types
  -- third param : the value of the variables - one or more depent how many we have
  execute sp_executesql @sql_v1, N'@salary int, @count int OUTPUT', @salary_i, @count OUTPUT -- we MUST NOT forget to use OUTPUT keyword 

 end
 declare @count_o int
exec spe_dynamic_count 100000, @count = @count_o output
select @count_o


 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         006
 -- -------------------------------------------------------------------------------------------------------------------------------------------
 
 go
 create or alter procedure spe_dynamic_temp_table
 as
 begin
   declare @sql nvarchar(max) 
   set @sql = 'create table #temp (id int) insert into #temp values (666) select * from #temp'
   exec sp_executesql @sql 
 end
 exec spe_dynamic_temp_table

 -- ---------------

 go
  create or alter procedure spe_dynamic_temp_table_v2
 as
 begin
   declare @sql nvarchar(max) 
   set @sql = 'create table #temp (id int) insert into #temp values (666)'
   exec sp_executesql @sql 
   select * from #temp
 end
 exec spe_dynamic_temp_table_v2

 -- ------------------

 go
  create or alter procedure spe_dynamic_temp_table_v3
 as
 begin
   create table #temp (id int)
   insert into #temp values(999)
   declare @sql  nvarchar(max)
   set @sql = 'select * from #temp'
   exec sp_executesql @sql
 end
 exec spe_dynamic_temp_table_v3

 -- -------------------------------------------------------------------------------------------------------------------------------------------
 --                                                         007
 -- -------------------------------------------------------------------------------------------------------------------------------------------

