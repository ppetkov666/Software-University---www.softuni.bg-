namespace Forum.Services
{
    using Forum.Models;

    public interface IUserService
    {
        // the first 3 methods will querie DB and it will return info
        User ById(int id);
        User ByUsername(string username);
        User ByUsernameAndPassword(string username, string password);
        // the last 2 methods will change the DB
        User Create(string username, string password);
        void Delete(int id);



    }
}
