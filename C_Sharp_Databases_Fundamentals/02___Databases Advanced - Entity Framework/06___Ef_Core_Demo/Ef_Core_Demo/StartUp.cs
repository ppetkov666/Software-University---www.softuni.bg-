namespace Ef_Core_Demo
{
    using Ef_Core_Demo.Data.Models;
    using System;
    using System.Linq;
    using Z.EntityFramework.Plus;

    public class StartUp
    {
        static void Main(string[] args)
        {
            EmployeesDbContext context = new EmployeesDbContext();
            //EmployeesDbContext secondContext = new EmployeesDbContext();

            //Employee first = context.Employees.Find(26);
            //Employee second = secondContext.Employees.Find(26);

            //first.Salary = 1000;
            //second.Salary = 2000;
            //// it will throw an exception because i have added attribute [ConcurrencyCheck] at employee class
            //try
            //{
            //    context.SaveChanges();
            //    secondContext.SaveChanges();
            //}
            //catch (Exception e)
            //{

            //    Console.WriteLine($"Error: {e.Message}");
            //}


            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            //var employees = context
            //    .Employees
            //    .Where(e => e.Salary < 20000)
            //    .Update(e => new Employee
            //    {
            //        Salary = e.Salary + 77
            //    });
            //context.SaveChanges();

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            //IQueryable<Employee> employees = context.Employees.Where(e => e.Salary < 20000);
            //foreach (var emp in employees)
            //{
            //    emp.Salary += 233;
            //}
            //context.SaveChanges();

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            // this is extension method and send only one querie
            //context.Employees.Where(e => e.Salary < 1050).Delete();
            // this is not efficient approach because sends much more queries depending of the where clause
            //IQueryable<Employee> employees = context.Employees.Where(e => e.Salary < 1050);
            //context.Employees.RemoveRange(employees);

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            //string querie = @"EXEC usp_UpdateSalary {0},{1}";
            //int result = context.Database.ExecuteSqlCommand(querie, 1, 234);

            //Console.WriteLine(result);

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            //Employee employee;
            //using (EmployeesDbContext context = new EmployeesDbContext())
            //{
            //    employee = context.Employees.Find(1);

            //    context.Entry(employee).State = EntityState.Detached;
            //    var secondEmployee = context.Employees.Find(2);

            //    var state1 = context.Entry(employee).State;
            //    var state2 = context.Entry(secondEmployee).State;

            //    // the changes for employee will not be applied because it is purposely detached
            //    employee.FirstName = "changed name";
            //    secondEmployee.FirstName = "Vankata";
            //    context.SaveChanges();
            //}

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------


            var employees = new[]
            {
                new Employee{FirstName = "george" , LastName = "georgiev2", Salary = 1000},
                new Employee{FirstName = "ivan" , LastName = "hanson", Salary = 2000},
                new Employee{FirstName = "michael" , LastName = "georgieff", Salary = 1040},
                new Employee{FirstName = "evon" , LastName = "clinton", Salary = 1500},
                new Employee{FirstName = "michael1" , LastName = "horvin", Salary = 17000},
                new Employee{FirstName = "john1" , LastName = "hanson", Salary = 2600},
                new Employee{FirstName = "bary1" , LastName = "jonees", Salary = 1440},
                new Employee{FirstName = "evon1" , LastName = "walls", Salary = 1900}
            };
            context.Employees.AddRange(employees);
            context.SaveChanges();

            // ---------------------------------------------------------------------------------------------------------------
            //EXAMPLE 
            // ---------------------------------------------------------------------------------------------------------------

            //native sql querie .... not the best way to be done, there are some limitations, and it can be use
            // in some very specific situation
            // in the example i have demonstrated how to avoid SQL Injection
            //string querie = @"SELECT Id, FirstName, LastName, Salary FROM Employees WHERE FirstName = {0}";
            //string firstName = "ivan";
            //Employee[] employees = context
            //    .Employees
            //    .FromSql(querie,firstName)
            //    .ToArray();
            //foreach (var emp in employees)
            //{
            //    Console.WriteLine(emp.ToString());
            //}
        }
    }
}
