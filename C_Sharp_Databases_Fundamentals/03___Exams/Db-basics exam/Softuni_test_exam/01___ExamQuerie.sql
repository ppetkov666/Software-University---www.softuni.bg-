
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

select * from Parts -- stock qty  is what we have available in stock
select * from PartsNeeded -- Quantity  is how many parts we need for the particular job 
select * from Orders -- delivered are how many are delivered for particular job 
select * from OrderParts -- for each order and part id we have  the quantities 

-- it is a tricky querie because if we dont include null records it won't return the right results
-- and it is the same for isnull function

    SELECT p.PartId,
	       p.[Description],
	       SUM(pn.Quantity)           AS [Required], 
	       SUM(p.StockQty)            AS [In Stock],
	       ISNULL(SUM(op.Quantity),0) AS Ordered 
      FROM Parts p
      JOIN PartsNeeded pn ON  pn.PartId = p.PartId
      JOIN Jobs j         ON    j.JobId = pn.JobId
LEFT  JOIN Orders o       ON    o.JobId = j.JobId
LEFT  JOIN OrderParts op  ON op.OrderId = o.OrderId
     WHERE j.[Status] <> 'Finished'
  GROUP BY p.PartId, p.[Description]
    HAVING SUM(pn.Quantity) > SUM(p.StockQty) + isnull(sum(op.Quantity),0)


------------------------------------------------------------------ task 17
GO

-- could be done in with case and if else 
-- i also added another solution just for test purposes to show how to return a table result from function
CREATE OR ALTER FUNCTION udf_GetCost(@Job_id int)
RETURNS DECIMAL(16,2)
AS
BEGIN 
DECLARE @Result DECIMAL(16,2)
    SET @Result = (SELECT SUM(op.Quantity *  p.Price) as Result
   FROM Jobs j
   JOIN Orders o      ON o.JobId = j.JobId
   JOIN OrderParts op ON op.OrderId = o.OrderId
   JOIN Parts p       ON p.PartId = op.PartId
  WHERE j.JobId = @Job_id)
  
  SELECT @Result =  CASE WHEN (ISNULL(@Result, 0) = 0) THEN 0 ELSE @result END
   
   --if (ISNULL(@Result, 0) = 0) 
   --begin
   --set @result = 0
   --end
 RETURN @result
END

GO
SELECT dbo.udf_GetCost(2)

GO

-- ------------------------------------------------------------------------
CREATE FUNCTION test_version(@job_id INT)
RETURNS  @rtnTable TABLE 
(
    -- columns returned by the function
    ID INT NOT NULL,
    Result DECIMAL(16,2) NOT NULL
)
AS
BEGIN 

    INSERT INTO @rtnTable
    SELECT p.PartId, SUM(op.Quantity *  p.Price) AS Result
      FROM Jobs j
      JOIN Orders o      ON o.JobId = j.JobId
      JOIN OrderParts op ON op.OrderId = o.OrderId
      JOIN Parts p       ON p.PartId = op.PartId
     WHERE j.JobId = @job_id
  GROUP BY p.PartId
 RETURN; 

END
GO

SELECT * FROM dbo.test_version(1)


------------------------------------------------------------------ task 18

SELECT * FROM Orders o WHERE o.JobId = 1 and ISNULL(o.IssueDate, '') = ''
SELECT * FROM Orders
GO
CREATE PROC usp_PlaceOrder
(
@job_id INT,
@part_serial_number VARCHAR(50),
@quantity INT
)
AS
BEGIN
 BEGIN TRY 
	DECLARE @order_id INT   SET @order_id = (SELECT TOP(1).OrderId -- WE CAN HAVE COUPLE ORDERS WITH THE SAME JOB ID AND THAT IS WHY SE USE top(1) 
											   FROM Orders o  
											  WHERE o.JobId = @job_id 
											    AND ISNULL(o.IssueDate, '') = '')
	-- because serial number is unique  we can have only one partId												
	DECLARE @part_id INT    SET @part_id = (SELECT p.PartId 
											  FROM Parts p 
											 WHERE p.SerialNumber = @part_serial_number)
	
	-- throw exceptions section
	-- if there is such a job id it means that will get in the if statement and will throw the error
	IF(ISNULL((SELECT j.JobId FROM Jobs j WHERE j.JobId = @job_id and j.[Status] = 'Finished'),0) <> 0)
	BEGIN
		;THROW 50011, 'This job is not active!', 1
	END
	
	IF(ISNULL((SELECT j.JobId FROM Jobs j WHERE j.JobId = @job_id),0) = 0)
	BEGIN
		;THROW 50013, 'Job not found!', 1
		
	END

	IF (@quantity <= 0)
	BEGIN
		;THROW 50012, 'Part quantity must be more than zero!', 1
	END


	IF(ISNULL(@part_id, 0) = 0)
	BEGIN
		;THROW 50014, 'Part not found!', 1
		
	END
	-- ----------------------------------------------------------------------------------------------------

	-- IF @order_id IS NULL IT MEANS WE JUST HAVE TO INSERT NEW RECORD INTO TABLE ORDERS
	IF(isnull(@order_id, 0) = 0 )
	BEGIN
		INSERT INTO Orders(JobId, IssueDate)
		VALUES
		(@job_id, null)
		-- BECAUSE OrderId IS IDENTITY COLUMN WE NEED TO HAVE IT TO INSERT IN THE OTHER TABLE - OrderParts
		-- THIS IS WHY I DECLARE @order_generated_id AND USE IT IN THE NEXT INSERT STATEMENT
		DECLARE @order_generated_id INT  SET @order_generated_id = (SELECT TOP(1) 
																		   o.OrderId 
																	  FROM Orders o 
																	 WHERE o.JobId = @job_id)

		INSERT INTO OrderParts(OrderId,PartId,Quantity)
		VALUES
		(@order_generated_id, @part_id, @quantity)
	END
	ELSE
	BEGIN
		-- IF PartId IS NULL IN THE MAPPING TABLE WE DO THE SAME AS ABOVE - INSERT THE NEW RECORD IN OrderParts.
		IF(ISNULL((SELECT op.PartId FROM OrderParts op WHERE op.OrderId = @order_id and op.PartId = @part_id),0) = 0 )
			BEGIN
			   INSERT INTO OrderParts(OrderId,PartId,Quantity)
			   VALUES
			   (@order_id,@part_id,@quantity)
			END
		ELSE
		-- WE UPDATE THE QUANTITY BECAUSE WE ALREADY CHECKED THAT SUCH A RECORD EXIST IN THE TABLE OrderParts
			BEGIN
				UPDATE OrderParts
				   SET Quantity += @quantity
			     WHERE OrderId = @order_id and PartId = @part_id 
			END
	END
		-- THIS COULB BE DONE WITH REVERSE CHECK BUT I THINK THE FIRST ONE IS EASIER TO READ
		--IF(ISNULL((SELECT op.PartId FROM OrderParts op WHERE op.OrderId = @order_id and op.PartId = @part_id),0) != 0 )
		--BEGIN
		--	UPDATE OrderParts
		--	   SET Quantity += @quantity
		--	 WHERE OrderId = @order_id and PartId = @part_id 
		--END
		--ELSE
		--	BEGIN
		--	 INSERT INTO OrderParts(OrderId,PartId,Quantity)
		--	 VALUES
		--	 (@order_id,@part_id,@quantity)
		--	END
		--END
 END TRY 
 BEGIN CATCH 
 END CATCH 
END
GO


------------------------------------------------------------------ task 19



SELECT * FROM Orders
SELECT * FROM OrderParts


go
CREATE OR ALTER TRIGGER tr_update_quantity ON Orders FOR Update 
AS

-- checking what records goes to table inserted and deleted 
 --select * from inserted i 
 --select * from deleted d 

 --select * 
 --  from inserted i
 --  join deleted d  on d.OrderId = i.OrderId

	UPDATE Parts
	   SET StockQty += op.Quantity
	  FROM Parts p
	  JOIN OrderParts op ON op.PartId = p.PartId
	  JOIN Orders o      ON o.OrderId = op.OrderId
	  JOIN inserted i    ON o.OrderId = i.OrderId
	  JOIN deleted d     ON d.OrderId = i.OrderId
	

-- just to test the result 
	GO
	BEGIN TRANSACTION
	UPDATE Orders
	   SET Delivered = 1
     WHERE OrderId = 21
  ROLLBACK

SELECT * FROM Parts
------------------------------------------------------------------ task 20


SELECT CONCAT(m.FirstName,' ',m.LastName) AS Mechanic,
	   v.[Name],
	   SUM(op.Quantity) AS Parts,
	   CONCAT(FLOOR((CAST(SUM(op.Quantity)AS FLOAT) / CAST(alias.[percent] AS FLOAT)) * 100),'%') as [Percentage]
  FROM Mechanics m 
  JOIN Jobs j        ON j.MechanicId = m.MechanicId
  JOIN Orders o      ON o.JobId = j.JobId
  JOIN OrderParts op ON op.OrderId = o.OrderId
  JOIN Parts p       ON p.PartId = op.PartId
  JOIN Vendors v     ON v.VendorId = p.VendorId
  
  JOIN (SELECT m.MechanicId mech_id,
			   SUM(op.Quantity) [percent] 
		  FROM Mechanics m 
          JOIN Jobs j                  ON j.MechanicId = m.MechanicId
          JOIN Orders o                ON o.JobId = j.JobId
          JOIN OrderParts op           ON op.OrderId = o.OrderId
          JOIN Parts p                 ON p.PartId = op.PartId
          JOIN Vendors v               ON v.VendorId = p.VendorId 
	  GROUP BY m.MechanicId ) AS alias ON   alias.mech_id = m.MechanicId
  GROUP BY m.FirstName, m.LastName,v.[name],alias.[percent]
  ORDER BY Mechanic, sum(op.Quantity)DESC, v.[Name]

  ------------------------------------------------------------------ test
  

