namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using System;
    public class ExitCommand : ICommand
    {
        public string Execute(params string[] arguments)
        {
            Environment.Exit(0);
            return $"You exit the program";
        }
    }
}
