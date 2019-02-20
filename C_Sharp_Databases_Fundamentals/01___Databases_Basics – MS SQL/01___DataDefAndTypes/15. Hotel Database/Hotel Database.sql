CREATE DATABASE Hotel;
GO

USE Hotel

CREATE TABLE Employees(
	Id INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(255) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees(Id,FirstName,LastName,Title)
VALUES
(1,'Petko','Petkov','Manager'),
(2,'Ivan','Ivanov','CO-Worker'),
(3,'Stamat','Avramov','Tech-Support')

CREATE TABLE Customers(
	AccountNumber INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(50),
	EmergencyName NVARCHAR(50) NOT NULL,
	EmergencyNumber INT NOT NULL,
	Notes NVARCHAR(50)
)

INSERT INTO Customers
(AccountNumber,FirstName,LastName,EmergencyName,EmergencyNumber)
VALUES
(1,'IVAN','IVANOV','IVANM',12345),
(2,'GEORGI','GEORGIEV','JOROm',23456),
(3,'JORO','JOROV','JOJOM',34567)

CREATE TABLE RoomStatus(
	RoomStatus NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO RoomStatus(RoomStatus)
VALUES
('Available'),
('Busy'),
('Reserved for VIP')

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes    NVARCHAR(MAX)
)

INSERT INTO RoomTypes(RoomType)
VALUES
('Basic'),
('Advanced'),
('Hyper-LUX')

CREATE TABLE BedTypes(
	BedType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes   NVARCHAR(MAX)
)

INSERT INTO BedTypes(BedType)
VALUES
('Small'),
('Large'),
('KingSize')

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY NOT NULL,
	RoomType NVARCHAR(50) NOT NULL,
	BedType NVARCHAR(50) NOT NULL,
	Rate DECIMAL(6, 2) NOT NULL,
	RoomStatus NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Rooms(RoomNumber,RoomType,BedType,Rate,RoomStatus)
VALUES
(1,'Basic','Small',100,'Available'),
(2,'Advanced','Large',150,'Busy'),
(3,'Hyper-LUX','KingSize',250,'Reserved for VIP')

CREATE TABLE Payments(
	Id INT PRIMARY KEY NOT NULL,
	EmployeeId INT NOT NULL,
	PaymentDate DATE NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATE NOT NULL,
	LastDateOccupied DATE NOT NULL,
	TotalDays INT NOT NULL,
	AmountCharged DECIMAL(6, 2) NOT NULL,
	TaxRate DECIMAL(6, 2) NOT NULL,
	TaxAmount DECIMAL(6, 2) NOT NULL,
	PaymentTotal DECIMAL(6, 2) NOT NULL,
	Notes NVARCHAR(MAX)
)

ALTER TABLE Payments
ADD CONSTRAINT CH_TotalDays
CHECK(DATEDIFF(DAY,FirstDateOccupied,LastDateOccupied) = TotalDays)

ALTER TABLE Payments
ADD CONSTRAINT CK_TaxAmount CHECK( TotalDays * TaxRate = TaxAmount);

INSERT INTO Payments
(Id,EmployeeId,PaymentDate,AccountNumber,FirstDateOccupied,LastDateOccupied,
TotalDays,AmountCharged,TaxRate,TaxAmount,PaymentTotal)
VALUES
(1,1,'01-01-2018',1,'01-01-2018','01-11-2018',10,100,50,500,100),
(2,2,'01-01-2018',2,'02-01-2018','02-11-2018',10,100,100,1000,100),
(3,3,'01-01-2018',3,'03-01-2018','03-11-2018',10,100,150,1500,100)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY NOT NULL,
	EmployeeId INT NOT NULL,
	DateOccupied DATE NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber INT NOT NULL,
	RateApplied DECIMAL(6, 2),
	PhoneCharge VARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Occupancies
(Id,EmployeeId,DateOccupied,AccountNumber,RoomNumber,PhoneCharge)
VALUES
(1,1,'06-06-2018',1,1,'+359 88 911 1111'),
(2,2,'07-07-2018',2,2,'+359 88 922 2222'),
(3,3,'08-08-2018',3,3,'+359 88 933 3333')
