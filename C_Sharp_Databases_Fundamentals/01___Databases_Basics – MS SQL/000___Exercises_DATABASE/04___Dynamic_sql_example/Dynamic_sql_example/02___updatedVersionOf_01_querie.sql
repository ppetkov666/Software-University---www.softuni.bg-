

-- with this SP and specially with order by clause and the input params i cover all the possible situations of Order By  with this input params in this order
use SoftUni
GO
CREATE OR ALTER PROCEDURE sp_dynamic_sql_querie
(
@i_order_by_first_name BIT = 0,
@i_order_by_last_name BIT = 0,
@i_order_by_salary BIT = 0
)
AS
BEGIN
	DECLARE @i_custom_select NVARCHAR (MAX); 
 SET   @i_custom_select = '
  SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY '
   IF(@i_order_by_first_name = 1 AND @i_order_by_last_name = 1 AND @i_order_by_salary = 1) BEGIN 
    SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.LastName ASC, e.Salary ASC'
    END;

   ELSE IF (@i_order_by_last_name = 1 AND @i_order_by_salary = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.LastName ASC, e.Salary ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 AND @i_order_by_salary = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.Salary ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 AND @i_order_by_last_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.LastName ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC'
    END;
   ELSE IF (@i_order_by_last_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.LastName ASC'
    END;
	ELSE IF (@i_order_by_salary = 1) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.Salary ASC'
    END;

EXEC (@i_custom_select)
END
GO
EXEC sp_dynamic_sql_querie @i_order_by_salary = 1
GO


-- this is just the querie left for test purposes only
 DECLARE @i_order_by_first_name BIT; 
     SET @i_order_by_first_name = 0;

 DECLARE @i_order_by_last_name BIT; 
     SET @i_order_by_last_name = 0;

 DECLARE @i_order_by_salary BIT; 
     SET @i_order_by_salary = 1;
 
 DECLARE @i_custom_select NVARCHAR (MAX); 
     SET   @i_custom_select = '
  SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY '
   IF(@i_order_by_first_name = 1 AND @i_order_by_last_name = 1 AND @i_order_by_salary = 1) BEGIN 
    SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.LastName ASC, e.Salary ASC'
    END;

   ELSE IF (@i_order_by_last_name = 1 AND @i_order_by_salary = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.LastName ASC, e.Salary ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 AND @i_order_by_salary = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.Salary ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 AND @i_order_by_last_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC, e.LastName ASC'
    END;
   ELSE IF (@i_order_by_first_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.FirstName ASC'
    END;
   ELSE IF (@i_order_by_last_name = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.LastName ASC'
    END;
	ELSE IF (@i_order_by_salary = 1) BEGIN        
	   SET @i_custom_select = @i_custom_select + 'e.Salary ASC'
    END;

PRINT @i_custom_select;
--EXEC (@i_custom_select)

-- just to compare result sets with test querie or SP
SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY E.FirstName,E.Salary,E.DepartmentID