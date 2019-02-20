
/*For the purpose of this task first we drop the constraint
ALTER TABLE Users
DROP CONSTRAINT [PK_USERS]*/

ALTER TABLE Users
ADD CONSTRAINT CHK_UsernameLength 
CHECK (LEN(Username) >= 3)
GO
/* we just check the constraint*/
INSERT INTO Users 
(Username,[Password], ProfilePicture,
LastLoginTime,IsDeleted) 
VALUES
	('Pe',HASHBYTES('SHA1','0123456'), null, CONVERT(DATETIME,'22-11-2017',103),0)


