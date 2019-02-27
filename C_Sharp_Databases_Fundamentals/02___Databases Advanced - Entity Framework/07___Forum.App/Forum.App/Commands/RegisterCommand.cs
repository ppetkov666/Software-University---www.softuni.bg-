namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using Forum.Models;
    using Forum.Services;
    public class RegisterCommand : ICommand
    {
        private readonly IUserService userService;
        public RegisterCommand(IUserService userService)
        {
            this.userService = userService;
        }
        public string Execute(params string[] arguments)
        {
            string userName = arguments[0];
            string password = arguments[1];

            var existingUser = userService.ByUsername(userName);
            if (existingUser != null)
            {
                return "This user is already registered";
            }
            userService.Create(userName,password);

            return $"User created Successfully!";
        }
    }
}
