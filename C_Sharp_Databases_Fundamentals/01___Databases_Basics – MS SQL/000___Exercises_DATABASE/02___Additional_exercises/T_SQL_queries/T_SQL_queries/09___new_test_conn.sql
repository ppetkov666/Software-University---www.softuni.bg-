CREATE TABLE #PersonDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO #PersonDetails
VALUES
('x'),
('y'),
('z')

select * from #PersonDetails
SELECT [NAME] FROM tempdb..sysobjects
WHERE NAME LIKE '%#PersonDetails%'

-- Global temp tables are accesible  because they are visible from all the connections
select * from ##EmployeeDetails

-- that's why i cannot create a table with the same name from this connection 
CREATE TABLE ##EmployeeDetails( 
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)
INSERT INTO ##EmployeeDetails
VALUES
('x'),
('y'),
('z')

SELECT * FROM ##EmployeeDetails