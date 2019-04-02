
 

 DECLARE @last_name              NVARCHAR (MAX); SET @last_name = '';
 declare @salary			     INT			 SET @salary = '';
 DECLARE @customselect nvarchar(max)
     SET @customselect = '
  SELECT * 
    FROM UserInfoTable uit
  WHERE (' + '''' + ISNULL(@last_name , '') + '''' + ' = '''' OR uit.LastName = ' + '''' + ISNULL(@last_name,'') + '''' + ') 
    AND (' + ISNULL(cast(@salary as nvarchar(50)), 0) + ' = 0 OR uit.Salary = ' + ISNULL(cast(@salary as nvarchar(50)),0) + ')
  order by uit.LastName'
   
  print @customselect
  exec SP_EXECUTESQL @customselect
  select * from UserInfoTable

  GO
 


 DECLARE @last_name              NVARCHAR (MAX); SET @last_name = 'PETKOV';
 
  SELECT * 
    FROM UserInfoTable uit
  WHERE (@last_name IS NULL OR @last_name = '' or  uit.LastName = @last_name ) 
  
  GO

  DECLARE @last_name              NVARCHAR (MAX); SET @last_name = '';
  SELECT * FROM UserInfoTable uit  where (isnull(@last_name,'') = '' or uit.LastName = @last_name)
  