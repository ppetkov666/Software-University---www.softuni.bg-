Create Database testTable 
GO

CREATE Table testTable(
	Id BIGINT Primary Key IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] BINARY(96) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTIme DATETIME,
	IsDeleted BIT
)
GO

INSERT INTO testTable 
(Username,[Password], ProfilePicture, IsDeleted) VALUES
	('Ivan11111',HASHBYTES('SHA1','012345'),null,0)
	
GO

ALTER TABLE TestTable
DROP CONSTRAINT [DF__testTable__LastL__5BE2A6F2]
GO

ALTER TABLE TestTable
ADD DEFAULT GETDATE() FOR LastLoginTime
GO

SELECT * FROM testTable