
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
	[Name] VARCHAR(50) NOT NULL UNIQUE, -- each model Name will be unique  
	CONSTRAINT [pk__Models] PRIMARY KEY(ModelId)
)

CREATE TABLE Jobs(
	JobId INT IDENTITY,
	ModelId INT NOT NULL,
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN ('Pending','In Progress','Finished')), -- it means Status must be:'Pending', 'In Progress' or'Finished' 
	ClientId INT  NOT NULL,
	MechanicId INT,
	IssueDate DATE NOT NULL,
	FinishDate DATE,
	CONSTRAINT [pk__Jobs] PRIMARY KEY(JobId),
	CONSTRAINT [fk__Jobs_Models] FOREIGN KEY(ModelId) REFERENCES Models(ModelId),
	CONSTRAINT [fk__Jobs_Clients] FOREIGN KEY(ClientId) REFERENCES Clients(ClientId),	 	 
	CONSTRAINT [fk__Jobs_Mechanics] FOREIGN KEY(MechanicId) REFERENCES Mechanics(MechanicId),
)


CREATE TABLE Orders(
	OrderId INT IDENTITY,
	JobId INT NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0, -- when we set default value we dont need to type not null
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
	SerialNumber VARCHAR(50)  NOT NULL UNIQUE, -- the serial number mus be unique
	[Description] VARCHAR(255), 
	Price DECIMAL(6,2) NOT NULL CHECK(Price >= 1), -- 9999.99 this is the maximum amount that;s why we set it to decimal(6,2)
	VendorId INT NOT NULL,
	StockQty INT DEFAULT 0 CHECK(StockQty >= 0), -- stock quantity cannot have negative value
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
	-- this is mapping table , we have composite primary key consisted of 2 fields(OrderId,PartId), and on the same time they are primary keys to their tables Orders, and Parts 
)

CREATE TABLE PartsNeeded(
	JobId INT,
	PartId INT,
	Quantity INT DEFAULT 1 CHECK(Quantity >= 1),
    CONSTRAINT PK_PartsNeeded PRIMARY KEY(JobId,PartId),
	CONSTRAINT [fk__PartsNeeded_Jobs] FOREIGN KEY(JobId) REFERENCES Jobs(JobId), 
	CONSTRAINT [fk__PartsNeeded_Parts] FOREIGN KEY(PartId) REFERENCES Parts(PartId) 
	-- the same as the table above
)

------------------------------------------------------------------ task 2
select * from Clients
select * from Parts
select * from Vendors

INSERT INTO Clients(FirstName,LastName,Phone)
VALUES
('Teri',' Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida',	'Corbley', '908-275-8357')


INSERT INTO Parts(SerialNumber,[Description],Price,VendorId)
VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod', 42.81, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

------------------------------------------------------------------ task 3

SELECT * FROM Mechanics

SELECT j.* 
  FROM Jobs j 
 WHERE j.MechanicId = 3 

 SELECT j.* 
   FROM jobs j 
  WHERE j.Status = 'Pending'

-- this is the final result but before that we must check the tables with teir relations
UPDATE j
   SET MechanicId = 3, j.[Status] = 'In Progress' 
  FROM Jobs j
 WHERE [Status] = 'Pending'


------------------------------------------------------------------ task 4

SELECT * 
  FROM OrderParts 
 WHERE OrderId = 19

SELECT * 
  FROM Orders 
 WHERE OrderId = 19

DELETE FROM OrderParts WHERE OrderId = 19
Delete FROM Orders     WHERE OrderId = 19


------------------------------------------------------------------ task 5
-- we execute the script 02___DdlDataSet.sql again 


  SELECT c.FirstName, c.LastName, c.Phone
    FROM Clients c
ORDER BY c.LastName,c.ClientId

------------------------------------------------------------------ task 6

  SELECT j.[Status],j.IssueDate 
    FROM Jobs j 
   WHERE j.[Status] != 'Finished'
ORDER BY j.IssueDate, 
	     j.JobId

------------------------------------------------------------------ task 7

SELECT * 
  FROM Mechanics

  SELECT CONCAT(m.FirstName,' ', m.LastName) AS Mechanic, 
	     j.[Status], 
	     j.IssueDate  
    FROM jobs j 
    JOIN Mechanics m ON m.MechanicId = j.MechanicId
ORDER BY j.MechanicId, 
		 j.IssueDate,
		 j.JobId 


------------------------------------------------------------------ task 8

SELECT * FROM Clients

SELECT CONCAT(c.FirstName,' ', c.LastName)    AS Client,
	   DATEDIFF(DAY,j.IssueDate,'2017/04/24') AS 'Days Going',
	   j.[Status]
  FROM Jobs j
  JOIN Clients c ON c.ClientId = j.ClientId
 WHERE j.[Status] != 'Finished'



------------------------------------------------------------------ task 9

select * from Mechanics

  SELECT CONCAT(m.FirstName,' ', m.LastName)           AS Mechanic,
    	 AVG(DATEDIFF(DAY,j.IssueDate,j.FinishDate)) AS [Average Days] 
    FROM jobs j 
    JOIN Mechanics m ON m.MechanicId = j.MechanicId 
   WHERE j.[Status] = 'Finished'
GROUP BY m.FirstName, m.LastName, j.MechanicId
ORDER BY j.MechanicId


------------------------------------------------------------------ task 10

   SELECT TOP(3) CONCAT(m.FirstName,' ', m.LastName)       AS Mechanic,
	      count(j.JobId)								   AS Jobs
     FROM jobs j 
     JOIN Mechanics m ON m.MechanicId = j.MechanicId
    WHERE j.[Status] != 'Finished'
 GROUP BY m.FirstName, m.LastName, m.MechanicId
   HAVING count(j.JobId) > 1
 ORDER BY Jobs DESC, m.MechanicId


------------------------------------------------------------------ task 11

select * from Mechanics

   SELECT CONCAT(m.FirstName,' ', m.LastName)       AS Mechanic 
     FROM Mechanics AS m
    WHERE m.MechanicId  NOT IN (SELECT j.MechanicId 
								  FROM jobs j 
								 WHERE [Status] != 'Finished' 
								   AND MechanicId is not null)
ORDER BY m.MechanicId

------------------------------------------------------------------ task 12

-- The specific part here is if the sum is NULL
select * from Parts

	SELECT ISNULL(SUM(P.Price * op.Quantity),0) AS [Parts Total]
	  FROM Parts p
	  JOIN OrderParts op ON op.PartId = p.PartId
	  JOIN Orders o ON o.OrderId = op.OrderId
	 WHERE DATEDIFF(WEEK, o.IssueDate,'2017-04-24') <= 3


------------------------------------------------------------------ task 13

    SELECT j.JobId,
		   ISNULL(SUM(p.Price * op.Quantity),0) AS Total
      FROM jobs j
 LEFT JOIN Orders o      ON o.JobId = j.JobId
 LEFT JOIN OrderParts op ON op.OrderId = o.OrderId
 LEFT JOIN Parts p       ON p.PartId =op.PartId
     WHERE j.[Status] = 'Finished'
  GROUP BY j.JobId
  ORDER BY Total DESC, 
		   j.JobId
	
------------------------------------------------------------------ task 14

-- we can use here not only concat but also Cast or some other function, but the final result will be the same

    SELECT m.ModelId,
	       m.[Name], 
	       CONCAT(AVG(DATEDIFF(DAY, IssueDate, FinishDate)), ' ', 'days') AS[Average Service Time]
      FROM Models m
 LEFT JOIN jobs j ON j.ModelId = m.ModelId
  GROUP BY m.ModelId, m.[Name]
  ORDER BY AVG(DATEDIFF(DAY, IssueDate, FinishDate))

------------------------------------------------------------------ task 15

-- specific querie ..  which if it is done in regular approach with one join after another it won't work properly
-- that's why the final sum is done by sub querie  and because of the task we are using WITH TIES

select * from Models

go
	(select  SUM(p.Price * op.Quantity) AS Total
		from  Orders o 
		join OrderParts op on op.OrderId = O.OrderId
		JOIN Parts p ON p.PartId = OP.PartId
		JOIN Jobs J ON J.JobId = o.JobId
		WHERE J.ModelId = 2)
go
 SELECT TOP 1 WITH TIES m.Name, 
		count(j.JobId) [Times Serviced],
		(select  isnull(SUM(p.Price * op.Quantity),0) AS Total
		   from  Orders o 
           join OrderParts op on op.OrderId = O.OrderId
           JOIN Parts p ON p.PartId = OP.PartId
           JOIN Jobs J ON J.JobId = o.JobId
          WHERE J.ModelId = m.ModelId)	[Parts Total]		
	 FROM Models m
	 JOIN jobs j ON j.ModelId = m.ModelId
 group by m.ModelId, m.Name
 order by [Times Serviced]desc


------------------------------------------------------------------ task 16


    select p.PartId,
	       p.[Description],
	       sum(pn.Quantity) as [Required], 
	       sum(p.StockQty) as [In Stock],
	       isnull(sum(op.Quantity),0) as Ordered 
      from Parts p
      join PartsNeeded pn on pn.PartId = p.PartId
      join Jobs j on j.JobId = pn.JobId
left  join Orders o on o.JobId = j.JobId
left  join OrderParts op on op.OrderId = o.OrderId
     where j.[Status] <> 'Finished'
  group by p.PartId, p.[Description]
    having sum(pn.Quantity) > sum(p.StockQty) + isnull(sum(op.Quantity),0)


------------------------------------------------------------------ task 17




------------------------------------------------------------------ task 18






------------------------------------------------------------------ task 19





------------------------------------------------------------------ task 20






