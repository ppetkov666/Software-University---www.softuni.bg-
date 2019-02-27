namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using Forum.Models;
    using Forum.Services;

    public class LoginCommand : ICommand
    {
        private readonly IUserService userService;
        public LoginCommand(IUserService userService)
        {
            this.userService = userService;
        }
        public string Execute(params string[] arguments)
        {
            string userName = arguments[0];
            string password = arguments[1];

            User user = userService.ByUsernameAndPassword(userName, password);
            if (user == null)
            {
                return "Invalid username or password";
            }

            Session.User = user;

            return $"Logged in successfully!";
        }
    }
}
