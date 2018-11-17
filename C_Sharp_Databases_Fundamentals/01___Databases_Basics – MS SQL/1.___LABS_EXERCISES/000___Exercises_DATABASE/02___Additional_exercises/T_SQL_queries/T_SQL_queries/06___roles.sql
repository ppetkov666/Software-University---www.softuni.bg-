
USE UserInfo

 SET ANSI_NULLS ON
GO
 SET QUOTED_IDENTIFIER ON
GO

GO
ALTER PROCEDURE spUserInfoTable_GetAll
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM UserInfoTable
END
GO

EXEC dbo.spUserInfoTable_GetAll

GO

CREATE PROCEDURE spUserInfoTable_GetUserByLastName 
(
  @LastName NVARCHAR(50)
)
AS
BEGIN
	SELECT * FROM UserInfoTable
	  WHERE LastName = @LastName
END

EXEC spUserInfoTable_GetUserByLastName @LastName = 'PETKOV'

GO
-- this is just  for security reasons - it hides the tables and and we can see only store procedures
-- after we create this role , then we have add a login - in this case is petko with pass petko, we have to map it and it is done 
CREATE ROLE dbStoredProcedureOnlyAccess
GRANT EXECUTE TO dbStoredProcedureOnlyAccess
GO
-- i use the next lines of code because of test pusposes 
sp_droprolemember  @rolename = 'dbStoredProcedureOnlyAccess' ,   
      @membername =  'test'  

GO

-- this is how to drop a login
DROP LOGIN test


select * from UserInfoTable