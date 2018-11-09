GO
CREATE OR ALTER PROCEDURE sp_dynamic_sql_querie
(
@i_order_by_first_name BIT,
@i_department_Id BIT,
@i_salary BIT
)
AS
BEGIN
	DECLARE @i_custom_select NVARCHAR (MAX); 
 SET   @i_custom_select = '
  SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY '
   IF(@i_order_by_first_name = 1 ) BEGIN 
    SET @i_custom_select = @i_custom_select + 'e.FirstName ASC'
	   IF (@i_department_Id = 1 ) BEGIN
	  SET @i_custom_select = @i_custom_select + ', e.Salary ASC'
	     IF (@i_salary = 1 ) BEGIN   
	    SET @i_custom_select = @i_custom_select + ', e.DepartmentID ASC'
        END;
	  END;
    END;

   ELSE IF (@i_department_Id = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + ' e.Salary ASC'
	       IF (@i_salary = 1 ) BEGIN   
		  SET @i_custom_select = @i_custom_select + ', e.DepartmentID ASC'
          END;
	   END;

   ELSE BEGIN   
	SET @i_custom_select = @i_custom_select + ' e.DepartmentID ASC'
   END;

EXEC (@i_custom_select)
END
GO
EXEC sp_dynamic_sql_querie 1,1,1
GO


-- this is just the querie left for test purposes only
 DECLARE @i_order_by_first_name BIT; 
     SET @i_order_by_first_name = 1;

 DECLARE @i_department_Id BIT; 
     SET @i_department_Id = 1;

 DECLARE @i_salary BIT; 
     SET @i_salary = 1;
 
 DECLARE @i_custom_select NVARCHAR (MAX); 
     SET   @i_custom_select = '
  SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY '
   IF(@i_order_by_first_name = 1 ) BEGIN 
    SET @i_custom_select = @i_custom_select + 'e.FirstName ASC'
	   IF (@i_department_Id = 1 ) BEGIN
	  SET @i_custom_select = @i_custom_select + ', e.Salary ASC'
	     IF (@i_salary = 1 ) BEGIN   
	    SET @i_custom_select = @i_custom_select + ', e.DepartmentID ASC'
        END;
	  END;
    END;

   ELSE IF (@i_department_Id = 1 ) BEGIN        
	   SET @i_custom_select = @i_custom_select + ' e.Salary ASC'
	       IF (@i_salary = 1 ) BEGIN   
		  SET @i_custom_select = @i_custom_select + ', e.DepartmentID ASC'
          END;
	   END;

   ELSE BEGIN   
	SET @i_custom_select = @i_custom_select + ' e.DepartmentID ASC'
   END;

--PRINT @i_custom_select;
EXEC (@i_custom_select)

-- just to compare result sets with test querie or SP
SELECT e.FirstName,e.LastName,e.Salary,d.[Name] [Department name],e.DepartmentID 
    FROM Employees e
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
ORDER BY E.FirstName,E.Salary,E.DepartmentID