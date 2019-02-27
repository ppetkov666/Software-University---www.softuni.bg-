namespace Forum.App
{
    using Forum.App.Commands.Contracts;
    using Forum.Data;
    using Forum.Models;
    using Forum.Services;
    using Forum.Services.Contracts;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.Extensions.DependencyInjection;
    using System;
    using System.Linq;
    using System.Text;

    public class Engine
    {
        private readonly IServiceProvider serviceProvider;
        public Engine(IServiceProvider serviceProvider)
        {
            this.serviceProvider = serviceProvider;
        }
        public void Run()
        {
            

            // this is the configuration through interfaces and because i use Run Method it is passed as param
            //IServiceProvider serviceProvider = ConfigureServices();
            // this is how i get instance of this service
            //IUserService userService = serviceProvider.GetService<IUserService>();
            //User userById = userService.ById(2);
            //Console.WriteLine($"{userById.Id} {userById.UserName} {userById.Password}");  


            IDataBaseInitializerService userServiceInitializeDB = serviceProvider.GetService<IDataBaseInitializerService>();
            userServiceInitializeDB.InitializeDatabase();

            while (true)
            {
                Console.Write("Enter Command: ");
                string input = Console.ReadLine();
                string[] commandTokens = input.Split(" ");

                string commandName = commandTokens.First();
                string[] commandArgs = commandTokens.Skip(1).ToArray();

                try
                {
                    ICommand command = CommandParser.ParseCommand(serviceProvider, commandName);
                    string result = command.Execute(commandArgs);
                    Console.WriteLine(result);
                }
                catch (InvalidOperationException e)
                {

                    Console.WriteLine(e.Message);
                }

                

            }
        }
    }
}
