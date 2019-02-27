namespace Forum.Services
{
    using Forum.Data;
    using Forum.Models;
    using System.Linq;

    public class UserService : IUserService
    {
        private readonly ForumDbContext context;
        //inversion of control  - we just pass the context in the constructor
        public UserService(ForumDbContext context)
        {
            this.context = context;
        }
        public User ById(int id)
        {
            User user = context.Users.Find(id);
            return user;
        }

        public User ByUsername(string username)
        {
            User user = context
                .Users
                .SingleOrDefault(u => u.UserName == username);
            return user;
        }

        public User ByUsernameAndPassword(string username, string password)
        {
            User user = context
                .Users
                .SingleOrDefault(u => u.UserName == username && u.Password == password);
            return user;
        }

        public User Create(string username, string password)
        {
            User user = new User(username, password);
            context.Users.Add(user);
            context.SaveChanges();
            return user;
        }

        public void Delete(int id)
        {
            User user = context.Users.Find(id);
            context.Users.Remove(user);
            context.SaveChanges();

        }
    }
}
