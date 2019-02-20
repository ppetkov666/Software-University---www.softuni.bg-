INSERT INTO Towns (Id,[Name])
VALUES
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna')
GO

INSERT INTO Minions (Id, [Name], Age, TownId)
VALUES
(1,'Kevin', 22, 1),
(2,'Bob', 15, 3),
(3,'Steward', null, 2)

GO

SELECT * FROM Minions
SELECT * FROM Towns