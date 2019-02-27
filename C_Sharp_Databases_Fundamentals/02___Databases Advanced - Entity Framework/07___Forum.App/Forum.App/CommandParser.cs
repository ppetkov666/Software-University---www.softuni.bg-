namespace Forum.App
{
    using Forum.App.Commands.Contracts;
    using System;
    using System.Linq;
    using System.Reflection;
    internal class CommandParser
    {
        internal static ICommand ParseCommand(IServiceProvider serviceProvider, string commandName)
        {
            Assembly assembly = Assembly.GetExecutingAssembly();
            // we get all classess who implement ICommand Interface
            Type[] commandTypes = assembly
                .GetTypes()
                .Where(t => t.GetInterfaces().Contains(typeof(ICommand)))
                .ToArray();
            //when we get all classess who implement ICommand  then we check for the commandName
            Type commandType = commandTypes.SingleOrDefault(c => c.Name == $"{commandName}Command");
            if (commandType == null)
            {
                throw new InvalidOperationException("Invalid Command!");
            }
            // then we have to make an instance  and that's why we are looking for constructors
            // it is always the first one by convention
            ConstructorInfo constructor = commandType.GetConstructors().First();
            // we take parameters of the constructor
            Type[] constructorParameters = constructor.GetParameters().Select(pi => pi.ParameterType).ToArray();
            // and once we have the constructor param  we pass it to service provider
            Object[] services = constructorParameters.Select(serviceProvider.GetService).ToArray();
            // and then we create instance , example:
            // new LoginCommand (new user service)
            ICommand command = (ICommand)constructor.Invoke(services);

            return command;
        }
    }
}