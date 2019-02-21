namespace One_to_Many_example_Entity_F_core_
{
    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Collections.Generic;
    using System.Linq;

    public class StartUp
    {
        static void Main(string[] args)
        {
            //using (MyDbContext db = new MyDbContext())
            //{
            //    //
            //    db.Database.EnsureDeleted();
            //    db.Database.EnsureCreated();
            //    Department department = new Department {Name = "Technical department"};

            //    for (int i = 0; i < 10; i++)
            //    {
            //        department.Employees.Add(new Employee { Name = $"employee - {i}", Age = 30 + i });
            //    }
            //    db.Add(department);
            //    db.SaveChanges();
            //}   

            int searchedDep = 1;
            bool isChecked = true;
            using (MyDbContext db = new MyDbContext())
            {
                //first way to get employees
                //Department searcherDepartment = db.Departments.Find(searchedDep);
                //List<Employee> employees = db.Employees.Where(e => e.Department.Id == searcherDepartment.Id).ToList();
                //foreach (var item in employees)
                //{
                //    Console.WriteLine(item.Id + " " + item.Name);
                //}


                // solution 2
                //var departmentV2 = db.Departments.Include(d => d.Employees);
                //foreach (var item in departmentV2)
                //{
                //    Console.WriteLine(item.Id + " " + item.Name);
                //    foreach (var employee in item.Employees)
                //    {
                //        Console.WriteLine(employee.Name + " " + employee.Age);
                //    }
                //}

                // solution 3
                //Department departmentV2 = db.Departments.Include(d => d.Employees).FirstOrDefault(d => d.Id == searchedDep);
                //List<Employee> employeesV2 = departmentV2.Employees;
                //Console.WriteLine(departmentV2.Name);
                //foreach (var employee in employeesV2)
                //{
                //    Console.WriteLine(employee.Name + " " + employee.Age);
                //}

                // another specific search 
                //if (isChecked)
                //{
                //    db.Entry(departmentV2)
                //        .Collection(d => d.Employees)
                //        .Query()
                //        .Where(e => e.Name.StartsWith("e"));
                //}

                //var result = db.Departments
                //    .Where(d => d.Id == searchedDep)
                //    .Select(d => new
                //    {
                //        name = d.Name,
                //        NumOfEmployees = d.Employees.Count
                //    })
                //    .FirstOrDefault();
                //Console.WriteLine($"Department {result.name} has {result.NumOfEmployees} employees");

                // this approach is much cleaner and readable
                Output result = db.Departments
                    .Where(d => d.Id == searchedDep)
                    .Select(d => new Output
                    {
                        Name = d.Name,
                        NumberOfEmployees = d.Employees.Count
                    })
                    .FirstOrDefault();
                Console.WriteLine($"Department {result.Name} has {result.NumberOfEmployees} employees");
            }
        }
    }
}
