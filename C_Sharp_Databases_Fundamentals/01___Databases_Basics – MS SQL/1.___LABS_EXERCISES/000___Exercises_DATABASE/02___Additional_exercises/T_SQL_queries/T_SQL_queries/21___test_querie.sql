



DECLARE @answer nvarchar(50)
EXEC udp_add_numbers 'second', @full_name = @answer OUTPUT 
SELECT CONCAT('the result is ',@answer) 'Final Answer'







DECLARE @FullName NVARCHAR(max)
EXEC f_MyCustomConcatProcedure @firstname = 'guy',@lastname = 'gilbert', @ConcatName = @FullName OUTPUT



EXEC udp_assign_employee_project 1,33



select e.FirstName,e.LastName,e.JobTitle,SUM(e.Salary) as totalsales
from Employees e
group by RollUp(e.FirstName,e.LastName,e.JobTitle)

select e.FirstName,e.LastName,e.JobTitle,SUM(e.Salary) as totalsales
from Employees e
group by Cube(e.FirstName,e.LastName,e.JobTitle)
