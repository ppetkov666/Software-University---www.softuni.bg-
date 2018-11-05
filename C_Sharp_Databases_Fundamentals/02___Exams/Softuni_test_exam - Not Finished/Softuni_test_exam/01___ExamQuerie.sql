
------------------------------------------------------------------ task 1
CREATE DATABASE DbExam
use dbExam

CREATE TABLE Clients(
	ClientId INT IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,	
	CONSTRAINT [pk__Clients] PRIMARY KEY(ClientId) 
)

CREATE TABLE Mechanics(
	MechanicId INT IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL,
	CONSTRAINT [pk__Mechanics] PRIMARY KEY(MechanicId) 	
)

CREATE TABLE Models(
	ModelId INT IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE,
	CONSTRAINT [pk__Models] PRIMARY KEY(ModelId)
)

CREATE TABLE Jobs(
	JobId INT IDENTITY,
	ModelId INT NOT NULL,
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN ('Pending','In Progress','Finished')),
	ClientId INT  NOT NULL,
	MechanicId INT,
	IssueDate DATE NOT NULL,
	FinishDate DATETIME,
	CONSTRAINT [pk__Jobs] PRIMARY KEY(JobId),
	CONSTRAINT [fk__Jobs_Models] FOREIGN KEY(ModelId) REFERENCES Models(ModelId),
	CONSTRAINT [fk__Jobs_Mechanics] FOREIGN KEY(MechanicId) REFERENCES Mechanics(MechanicId),
	CONSTRAINT [fk__Jobs_Clients] FOREIGN KEY(ClientId) REFERENCES Clients(ClientId)	 	 
)

CREATE TABLE Orders(
	OrderId INT IDENTITY,
	JobId INT NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0,
	CONSTRAINT [pk__Orders] PRIMARY KEY(OrderId),
	CONSTRAINT [fk__Orders_Jobs] FOREIGN KEY(JobId) REFERENCES Jobs(JobId) 
)

CREATE TABLE Vendors(
	VendorId INT IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE,
	CONSTRAINT [pk__Vendors] PRIMARY KEY(VendorId)
)

CREATE TABLE Parts(
	PartId INT IDENTITY,
	SerialNumber VARCHAR(50)  NOT NULL UNIQUE,
	[Description] VARCHAR(255), 
	Price DECIMAL(6,2) NOT NULL CHECK(Price >= 1),
	VendorId INT NOT NULL,
	StockQty INT DEFAULT 0 CHECK(StockQty >= 0),
	CONSTRAINT [pk__Parts] PRIMARY KEY(PartId),
	CONSTRAINT [fk__Parts_Vendors] FOREIGN KEY(VendorId) REFERENCES Vendors(VendorId) 
)

CREATE TABLE OrderParts(
	OrderId INT,
	PartId INT,
	Quantity INT DEFAULT 1 CHECK(Quantity >= 1),
    CONSTRAINT PK_OrderParts PRIMARY KEY(OrderId,PartId),
	CONSTRAINT [fk__OrderParts_Orders] FOREIGN KEY(OrderId) REFERENCES Orders(OrderId), 
	CONSTRAINT [fk__OrderParts_Parts] FOREIGN KEY(PartId) REFERENCES Parts(PartId) 
)

CREATE TABLE PartsNeeded(
	JobId INT,
	PartId INT,
	Quantity INT DEFAULT 1 CHECK(Quantity >= 1),
    CONSTRAINT PK_PartsNeeded PRIMARY KEY(JobId,PartId),
	CONSTRAINT [fk__PartsNeeded_Jobs] FOREIGN KEY(JobId) REFERENCES Jobs(JobId), 
	CONSTRAINT [fk__PartsNeeded_Parts] FOREIGN KEY(PartId) REFERENCES Parts(PartId) 
)



------------------------------------------------------------------ task 2

INSERT INTO Clients(FirstName,LastName,Phone)
VALUES
('Teri',' Ennaco', 570-889-5187),
('Merlyn', 'Lawler', 201-588-7810),
('Georgene', 'Montezuma', 925-615-5185),
('Jettie', 'Mconnell', 908-802-3564),
('Lemuel', 'Latzke', 631-748-6479),
('Melodie', 'Knipp', 805-690-1682),
('Candida',	'Corbley', 908-275-8357)
------------------------------------------------------------------ task 3



















