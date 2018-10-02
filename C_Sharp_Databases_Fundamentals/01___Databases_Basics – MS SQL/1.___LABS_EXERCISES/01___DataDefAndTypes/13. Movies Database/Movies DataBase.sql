CREATE DATABASE Movies

USE Movies
GO 

CREATE TABLE Directors(
	Id INT PRIMARY KEY NOT NULL,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)  
)
GO

INSERT INTO Directors(Id, DirectorName)
VALUES
(1,'FIRST BOSS'),
(2,'SECOND BOSS'),
(3,'THIRD BOSS'),
(4,'FOURTH BOSS'),
(5,'FIFTH BOSS')
GO

CREATE TABLE Genres(
	Id INT PRIMARY KEY NOT NULL,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)
GO

INSERT INTO Genres(Id, GenreName)
VALUES
(1,'ACTION'),
(2,'COMEDY'),
(3,'DRAMA'),
(4,'SCARRY'),
(5,'ACTION')
GO

CREATE TABLE Categories(
	Id INT PRIMARY KEY NOT NULL,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
) 
GO

INSERT INTO Categories(Id, CategoryName)
VALUES
(1,'first category'),
(2,'second category'),
(3,'third category'),
(4,'fourth category'),
(5,'fifth category')
GO

--Id, Title, DirectorId, CopyrightYear, Length, 
--GenreId, CategoryId, Rating, Notes
CREATE TABLE Movies(
	Id INT PRIMARY KEY NOT NULL,
	Title NVARCHAR(255) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear INT,
	[Length] NVARCHAR(50),
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating INT,
	Notes NVARCHAR(MAX)
)
GO

-- just for example how to do it with alter table option
--ALTER TABLE Movies 
--ADD CONSTRAINT FK_Movies_Genres
--FOREIGN KEY (GenreId) REFERENCES Genres(Id)

INSERT INTO Movies(Id, Title, DirectorId, GenreId, CategoryId)
VALUES
(1,'first',1,2,3),
(2,'second',2,3,3),
(3,'third',3,4,3),
(4,'fourth',4,5,2),
(5,'fifth',5,2,1)
SELECT * FROM Movies