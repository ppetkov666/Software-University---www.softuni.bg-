namespace DbFirstDemoSqlServer
{
    using DbFirstDemoSqlServer.Data;
    using DbFirstDemoSqlServer.Data.Models;
    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Collections.Generic;
    using System.Linq;

    public class StartUp
    {
        static void Main(string[] args)
        {
            using (SoftUniDbContext context = new SoftUniDbContext())
            {

                List<Town> towns = context.Towns
                                   .Include(a=>a.Addresses)
                                   .ThenInclude(a=>a.Employees)
                                   .OrderBy(e=>e.Addresses.Count)
                                   .ToList();
                foreach (Town town in towns)
                {
                    Console.WriteLine($"{town.TownId} {town.Name} has {town.Addresses.Count} addresses");
                    foreach (Address address in town.Addresses)
                    {
                        Console.WriteLine($"{address.Employees.Count} people on {address.AddressText}");
                        foreach (var emp in address.Employees)
                        {
                            Console.WriteLine($"{emp.FirstName} {emp.LastName}");
                        }
                    }
                    Console.WriteLine();
                }


                //var empToFire = context.Employees.Find(1);
                //Console.WriteLine(empToFire.FirstName);

                //var employee = context.Employees.Include(e=>e.Department)
                //    .FirstOrDefault(e => e.FirstName == "guy");
                
                //Console.WriteLine($"{employee.FirstName} {employee.Department.Name}");

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