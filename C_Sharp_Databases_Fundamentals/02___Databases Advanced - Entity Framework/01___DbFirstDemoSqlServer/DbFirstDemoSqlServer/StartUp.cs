namespace DbFirstDemoSqlServer
{
    using DbFirstDemoSqlServer.Data;
    using DbFirstDemoSqlServer.ViewModels;
    using System;
    using System.Linq;
    public class StartUp
    {
        static void Main(string[] args)
        {
            using (SoftUniDbContext context = new SoftUniDbContext())
            {

                var employees = context
                    .Employees
                    .Select(e => new EmployeeProfileViewModel(e));


                foreach (var emp in employees)
                {
                    Console.WriteLine(emp.ToString());
                }

                //-------------------------------------------------------------------------------------------------
                //                                       example 1
                //-------------------------------------------------------------------------------------------------

                //var townEmpCount = context
                //    .Employees
                //    .GroupBy(t => t.Address.Town.Name)
                //    .Select(g => new TownViewModel(g.Key, g.Count()))
                //    .OrderByDescending(g=>g.ResidentCount)
                //    .ToArray();

                //foreach (var townViewModel in townEmpCount)
                //{
                //    Console.WriteLine($"{townViewModel.Name} has {townViewModel.ResidentCount} people");
                //}

                //-------------------------------------------------------------------------------------------------
                //                                       example 2
                //-------------------------------------------------------------------------------------------------
                // RESIDENT COUNT says : give me the the count of emp per town , but the problem is this querie  when is executed 
                // like this is very UN eficient  unlike if executed with SP using ADO and with pure SQL querie
                //var townEmpCount = context
                //    .Towns
                //    .Select(t => new
                //    {
                //        TownName = t.Name,
                //        ResidentCount = t.Addresses.Sum(a => a.Employees.Count)
                //    })
                //    .OrderByDescending(t=>t.ResidentCount);
                //foreach (var tec in townEmpCount)
                //{
                //    Console.WriteLine($"{tec.TownName} has {tec.ResidentCount} people");
                //}

                //-------------------------------------------------------------------------------------------------
                //                                       example 3
                //-------------------------------------------------------------------------------------------------

                //List<Town> towns = context.Towns
                //                   .Include(a=>a.Addresses)
                //                   .ThenInclude(a=>a.Employees)
                //                   .OrderBy(e=>e.Addresses.Count)
                //                   .ToList();
                //foreach (Town town in towns)
                //{
                //    Console.WriteLine($"{town.TownId} {town.Name} has {town.Addresses.Count} addresses");
                //    foreach (Address address in town.Addresses)
                //    {
                //        Console.WriteLine($"{address.Employees.Count} people on {address.AddressText}");
                //        foreach (var emp in address.Employees)
                //        {
                //            Console.WriteLine($"{emp.FirstName} {emp.LastName}");
                //        }
                //    }
                //    Console.WriteLine();
                //}

                //-------------------------------------------------------------------------------------------------
                //                                       example 4
                //-------------------------------------------------------------------------------------------------

                //var empToFire = context.Employees.Find(1);
                //Console.WriteLine(empToFire.FirstName);

                //var employee = context.Employees.Include(e=>e.Department)
                //    .FirstOrDefault(e => e.FirstName == "guy");

                //Console.WriteLine($"{employee.FirstName} {employee.Department.Name}");

                //-------------------------------------------------------------------------------------------------
                //                                       example 5
                //-------------------------------------------------------------------------------------------------


                //var employees = context.Employees
                //    .Select(e => new
                //{
                //    e.FirstName,
                //    e.LastName,
                //    e.JobTitle
                //}).GroupBy(e => e.JobTitle).OrderByDescending(g=>g.Count()).ToList();

                //foreach (var group in employees)
                //{
                //    Console.WriteLine($"{group.Key} - {group.Count()}");
                //    foreach (var emp in group)
                //    {
                //        Console.WriteLine($"{emp.FirstName} {emp.LastName} - {emp.JobTitle}");
                //    }
                //}
            }
        }
    }
}