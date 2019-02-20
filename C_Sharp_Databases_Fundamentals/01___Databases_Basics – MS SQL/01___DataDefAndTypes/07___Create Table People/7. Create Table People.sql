CREATE TABLE People(
	Id INT UNIQUE IDENTITY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height NUMERIC(3,2),
	[Weight] NUMERIC(5,2), 
	Gender CHAR(1) CHECK ([GENDER] IN ('M','F')) NOT NULL, 
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX), 
)
GO

ALTER TABLE People
ADD PRIMARY KEY(Id)
GO

ALTER TABLE People
ADD CONSTRAINT CH_PictureSize
CHECK (DATALENGTH(Picture) <= 2 * 1024 * 1024)
GO

INSERT INTO People([Name], Gender, Birthdate)
VALUES
('Petko Petkov', 'M', '01/01/1901'),
('Jenia Ivanova', 'F', '02/02/1902'),
('Petko Georgiev', 'M', '03/03/1903'),
('Petko Tanchev', 'M', '04/04/1904'),
('Petko Stamatov', 'M', '05/05/1905')

SELECT * FROM People
