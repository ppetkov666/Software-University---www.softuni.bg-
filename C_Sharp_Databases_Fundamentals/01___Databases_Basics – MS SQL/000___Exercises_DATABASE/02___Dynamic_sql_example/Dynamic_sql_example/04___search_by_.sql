Create or alter Procedure spe_search_employees
@first_name nvarchar(100) = null,
@last_name nvarchar(100) = null,
@salary int = null
As
Begin
     Select * 
       from Employees 
      where 
      
      ((FirstName = @first_name OR @first_name is null) and 
      (LastName  = @last_name   OR @last_name is null)  and 
      (Salary  = @salary        OR @salary is null))   

End
Go


















































































  