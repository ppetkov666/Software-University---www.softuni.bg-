namespace Forum.App
{
    using Forum.Data;
    using Forum.Models;
    using Forum.Services;
    using Forum.Services.Contracts;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.Extensions.DependencyInjection;
    using System;
    using System.Text;

    public class Engine
    {
        public void Run(IServiceProvider serviceProvider)
        {
            // after installing Microsoft.Extensions.DependencyInjection package IServiceProvider:

            // this is the configuration through interfaces 
            //IServiceProvider serviceProvider = ConfigureServices();
            // this is how i get instance of this service
            //IUserService userService = serviceProvider.GetService<IUserService>();
            //User userById = userService.ById(2);
            //Console.WriteLine($"{userById.Id} {userById.UserName} {userById.Password}");  

            var userServiceInitializeDB = serviceProvider.GetService<IDataBaseInitializerService>();
            userServiceInitializeDB.InitializeDatabase();

            while (true)
            {
                Console.Write("Enter Command");
                string input = Console.ReadLine();
                string[] commandTokens = input.Split(" ");


            }
        }
    }
}
