CREATE DATABASE CarRental

USE CarRental
GO

CREATE TABLE Categories(
	Id INT PRIMARY KEY NOT NULL,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(6,2),
	WeeklyRate DECIMAL(6,2),
	MonthlyRate DECIMAL(6,2),
	WeekendRate DECIMAL(6,2)
)
GO
-- here instead of entering NOT NULL on every rate , i will make a constraint

ALTER TABLE Categories
ADD CONSTRAINT CH_CheckRates 
CHECK(
(DailyRate IS NOT NULL) OR
(WeeklyRate IS NOT NULL) OR
(MonthlyRate IS NOT NULL) OR
(WeekendRate IS NOT NULL)
)
GO

INSERT INTO Categories
(Id, CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
(1,'firstCat.',100, 200, 300, 150),
(2,'secondCat.',200, 300, 400, 250),
(3,'thirdCat.',300, 400, 500, 350)
GO

CREATE TABLE Cars(
	Id INT PRIMARY KEY NOT NULL,
	PlateNumber  NVARCHAR(50) NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	CarYear INT NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Doors BINARY NOT NULL,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(50),
	Available BIT DEFAULT 1
)
GO

INSERT INTO Cars
(Id,PlateNumber,Manufacturer,Model,CarYear,CategoryId,Doors,Available)
VALUES
(1,'C?4455??','Audi','A4',2017,1,2,1),
(2,'C3335??','BMW','3series',2018,2,2,1),
(3,'B1123??','Mercedes','Eclass',2018,3,2,1)
GO

CREATE TABLE Employees(
	Id INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)
GO

INSERT INTO Employees(Id,FirstName,LastName,Title)
VALUES
(1,'Ivan','Ivanov','support'),
(2,'Geogi','Georgiev','tech support'),
(3,'Petar','Petrov','CEO')
GO

CREATE TABLE Customers(
	Id INT PRIMARY KEY NOT NULL,
	DriverLicenceNumber NVARCHAR(50)UNIQUE NOT NULL,
	FullName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(255),
	City NVARCHAR(50),
	ZIPCode NVARCHAR(50),
	Notes NVARCHAR(MAX)
)
GO

INSERT INTO Customers(Id,DriverLicenceNumber,FullName)
VALUES
(1,'C4475??','Georgi Georgiev'),
(2,'?4055??','Petar Petkov'),
(3,'C4405??','Stamat Ivanov')
GO

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL,
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
	TankLevel NUMERIC(6, 2),
	KilometrageStart INT,
	KilometrageEnd INT,
	TotalKilometrage INT,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	TotalDays INT NOT NULL, 
	RateApplied DECIMAL(10, 2),
	TaxRate DECIMAL(10, 2),
	OrderStatus NVARCHAR(50),
	NOTES NVARCHAR(MAX)
)
GO

ALTER TABLE RentalOrders
ADD CONSTRAINT CK_TotalDays 
CHECK(DATEDIFF(DAY, StartDate, EndDate) = TotalDays);
GO

INSERT INTO RentalOrders
(Id,EmployeeId,CustomerId,CarId,StartDate,EndDate,TotalDays)
VALUES
(1,1,1,1,'01-01-2017','01-02-2017',1),
(2,2,2,2,'02-02-2017','02-04-2017',2),
(3,3,3,3,'03-03-2017','03-04-2017',1)