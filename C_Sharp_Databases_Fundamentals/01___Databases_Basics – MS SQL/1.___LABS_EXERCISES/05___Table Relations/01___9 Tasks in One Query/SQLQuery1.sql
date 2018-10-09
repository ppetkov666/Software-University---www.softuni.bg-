/*****************************************************
Problem 1.	One-To-One Relationship
******************************************************/
CREATE TABLE Passports(
	PassportID	INT NOT NULL,
	PassportNumber NVARCHAR(255)

	CONSTRAINT PK_Passports PRIMARY KEY(PassportID)
)
INSERT INTO Passports 
VALUES
(101,'N34FG21B'),
(102,'K65LO4R7'),
(103,'ZE657QP2')

CREATE TABLE Persons(
	PersonID INT NOT NULL,	
	FirstName VARCHAR(32) NOT NULL,	
	Salary	DECIMAL(15,4),
	PassportID INT

	CONSTRAINT PK_Persons PRIMARY KEY(PersonID),
	CONSTRAINT FK_Persons_Passports 
	FOREIGN KEY(PassportID)
	REFERENCES Passports(PassportID)
)
INSERT INTO Persons 
VALUES
(1,'Roberto', 43300.00,	102),
(2, 'Tom',56100.00, 103),
(3,	'Yana',	60200.00, 101)

/*****************************************************
Problem 2.	One-To-Many Relationship
******************************************************/

CREATE TABLE Manufacturers(
	ManufacturerID	INT NOT NULL,
	[Name] VARCHAR(32)	NOT NULL,
	EstablishedOn DATE DEFAULT GETDATE()

	CONSTRAINT PK_Manufacturers PRIMARY KEY(ManufacturerID)
)

CREATE TABLE Models(
	ModelID	INT NOT NULL,
	[Name] VARCHAR(32)	NOT NULL,
	ManufacturerID INT NOT NULL

	CONSTRAINT PK_Models PRIMARY KEY(ModelID)
	CONSTRAINT FK_Models_Manufacturers 
	FOREIGN KEY(ManufacturerID)
	REFERENCES Manufacturers(ManufacturerID)
)
INSERT INTO Manufacturers
VALUES
(1,'BMW', CONVERT(DATE,'07/03/1916',103)),
(2,'Tesla', CONVERT(DATE,'01/01/2003',103)),
(3,'Lada', CONVERT(DATE,'01/05/1966',103))

INSERT INTO Models
VALUES
(101,'X1',1),
(102,'i6',1),
(103,'Model S',2),
(104,'Model X',2),
(105,'Model 3',2),
(106,'Nova',3)

/*****************************************************
Problem 3.	Many-To-Many Relationship
******************************************************/

CREATE TABLE Students(
	StudentID INT NOT NULL,	
	[Name] VARCHAR(32)

	CONSTRAINT PK_Students PRIMARY KEY(StudentID)
)
CREATE TABLE Exams(
	ExamID INT NOT NULL,	
	[Name] VARCHAR(32)

	CONSTRAINT PK_Exams PRIMARY KEY(ExamID)
)
CREATE TABLE StudentsExams(
	StudentID INT NOT NULL,	
	ExamID INT NOT NULL

	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID,ExamID)

	CONSTRAINT FK_StudentsExams_StudentID
	FOREIGN KEY(StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_StudentsExams_ExamID
	FOREIGN KEY(ExamID)
	REFERENCES Exams(ExamID)
)
INSERT INTO Students
VALUES
(1, 'Mila'),                                     
(2, 'Toni'),
(3,	'Ron')

INSERT INTO Exams
VALUES
(101,'SpringMVC'),                                     
(102,'Neo4j'),
(103,'Oracle 11g')


/*****************************************************
Problem 4.	Self-Referencing 
******************************************************/

CREATE DATABASE Demo
USE Demo
CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY NOT NULL,	
	[Name] NVARCHAR(32),	
	ManagerID INT
)
--select * from Teachers
ALTER TABLE Teachers
ADD CONSTRAINT FK_Teachers_ManagerID 
FOREIGN KEY(ManagerID) 
REFERENCES Teachers(TeacherID)

-- must be inserted at onece because it is part of one transaction
INSERT INTO Teachers VALUES
(101,'John',NULL),
(102,'Maya',106),
(103,'Silvia',106),
(104,'Ted',105),
(105,'Mark',101),
(106,'Greta',101)

/*****************************************************
Problem 5.	Online Store Database
******************************************************/

CREATE DATABASE [Online Store]
USE [Online Store]
CREATE TABLE Cities(
	CityID INT NOT NULL, -- ADD PRIMARY
	[Name] VARCHAR(50) NOT NULL -- ADD CHECK CONSTRAINT
)
CREATE TABLE Customers(
	CustomerID INT NOT NULL, -- ADD PRIMARY
	[Name] VARCHAR(50) NOT NULL, -- ADD CHECK CONSTRAINT
	Birthday DATE NOT NULL,
	CityID INT NOT NULL -- ADD FOREIGN
)
CREATE TABLE Orders(
	OrderID INT NOT NULL, -- ADD PRIMARY
	CustomerID INT NOT NULL -- ADD FOREIGN 
)
CREATE TABLE ItemTypes(
	ItemTypeID INT NOT NULL, -- ADD PRIMARY
	[Name] VARCHAR(50) NOT NULL -- ADD CHECK CONSTRAINT
)
CREATE TABLE Items(
	ItemID INT NOT NULL, -- ADD PRIMARY
	[Name] VARCHAR(50) NOT NULL, -- ADD CHECK CONSTRAINT
	ItemTypeID INT NOT NULL -- ADD FOREIGN KEY
)
CREATE TABLE OrderItems(
	OrderID INT NOT NULL,
	ItemID INT NOT NULL
)

ALTER TABLE Cities
ADD CONSTRAINT PK_Cities PRIMARY KEY (CityID),
	CONSTRAINT CHK_NameOfTheCity CHECK(LEN([Name]) > 2) 

ALTER TABLE Customers
ADD CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
	CONSTRAINT CHK_CustomerName CHECK(LEN([Name]) > 2),
	CONSTRAINT FK_Customers_Cities 
	FOREIGN KEY(CityID)
	REFERENCES Cities(CityID) 

ALTER TABLE Orders
	ADD CONSTRAINT PK_Orders PRIMARY KEY(OrderID),
		CONSTRAINT FK_Orders_Customers 
		FOREIGN KEY(CustomerID)
		REFERENCES Customers(CustomerID)

ALTER TABLE ItemTypes
ADD CONSTRAINT PK_ItemTypes PRIMARY KEY (ItemTypeID),
	CONSTRAINT CHK_ItemTypeName CHECK(LEN([Name]) > 2) 

ALTER TABLE Items
ADD CONSTRAINT PK_Items PRIMARY KEY (ItemID),
	CONSTRAINT CHK_ItemName CHECK(LEN([Name]) > 2),
	CONSTRAINT FK_Items_ItemsType 
	FOREIGN KEY(ItemTypeID)
	REFERENCES ItemTypes(ItemTypeID)
	 
ALTER TABLE OrderItems
	ADD CONSTRAINT PK_OrderItems PRIMARY KEY(OrderID,ItemID),
		CONSTRAINT FK_OrderITems_Orders 
		FOREIGN KEY(OrderID)
		REFERENCES Orders(OrderID),
		CONSTRAINT FK_OrderITems_Items 
		FOREIGN KEY(ItemID)
		REFERENCES Items(ItemID)

-- JUST AN EXAMPLE HOW TO CHOOSE PROPERLY VARIABLES AND DATA TYPES
-- IT IS NOT PART OF THIS TASK
DECLARE @FirstName VARCHAR(50) = 'Petko'
DECLARE @LastName CHAR(50) = 'Petko'
SELECT DATALENGTH(@FirstName), DATALENGTH(@LastName)

-- ANOTHER BONUS TASK  HOW TO RENAME A TABLE
CREATE TABLE Fakeitems(
		Id INT
)
EXEC sp_rename 'Fakeitems','TrueItems'

select * from TrueItems

/*****************************************************
Problem 6.	University Database
******************************************************/

CREATE DATABASE University

USE University

CREATE TABLE Majors(
	MajorID INT NOT NULL,
	[Name] NVARCHAR(32) NOT NULL,
	
	CONSTRAINT PK_Majors PRIMARY KEY(MajorID),
	CONSTRAINT CHK_MajorName CHECK(LEN([Name]) > 2)
)

CREATE TABLE Students(
	StudentID INT NOT NULL,
	StudentNumber CHAR(10) NOT NULL,
	StudentName VARCHAR(32),
	MajorID INT,
	CONSTRAINT PK_Students PRIMARY KEY(StudentID),
	CONSTRAINT CHK_StudentName CHECK(LEN(StudentName) > 2),

	CONSTRAINT FK_Students_Majors 
	FOREIGN KEY(MajorID) 
	REFERENCES Majors(MajorID)
)

CREATE TABLE Subjects(
	SubjectID   INT NOT NULL,
	SubjectName VARCHAR(32) NOT NULL,
	
	CONSTRAINT PK_Subjects PRIMARY KEY(SubjectID)
)

CREATE TABLE Agenda(
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL,
	CONSTRAINT PK_Agenda_StudentID_SubjectID PRIMARY KEY(StudentID, SubjectID),

	CONSTRAINT FK_Agenda_Students 
	FOREIGN KEY(StudentID) 
	REFERENCES Students(StudentID),

	CONSTRAINT FK_Agenda_Subjects 
	FOREIGN KEY(SubjectID) 
	REFERENCES Subjects(SubjectID)
)

CREATE TABLE Payments(
	PaymentID     INT NOT NULL,
	PaymentDate   DATETIME DEFAULT GETDATE() NOT NULL,
	PaymentAmount DECIMAL(15, 2) NOT NULL,
	StudentID     INT NOT NULL,
	
	CONSTRAINT PK_Payments PRIMARY KEY(PaymentID),

	CONSTRAINT FK_Payments_Students 
	FOREIGN KEY(StudentID) 
	REFERENCES Students(StudentID)
)
GO
/*****************************************************
Problem 7.	SoftUni Design
******************************************************/

-- This Task is just to Explore E/R Diagrams ! 

/*****************************************************
Problem 8.	Geography Design
******************************************************/

-- This Task is just to Explore E/R Diagrams ! 

/*****************************************************
Problem 9.	*Peaks in Rila
******************************************************/
USE Geography

SELECT Mountains.MountainRange,Peaks.PeakName,Peaks.Elevation
FROM Mountains
JOIN Peaks ON Peaks.MountainId = Mountains.Id
WHERE MountainRange = 'Rila'
ORDER BY Elevation DESC