namespace Forum.Services
{
    using Forum.Models;

    public interface IUserService
    {
        // the first 3 methods will querie DB and it will return info
        TModel ById<TModel>(int id);
        //User ById(int id);
        TModel ByUsername<TModel>(string username);
        //User ByUsername(string username);
        TModel ByUsernameAndPassword<TModel>(string username, string password);
        //User ByUsernameAndPassword(string username, string password);

        // the last 2 methods will change the DB
        TModel Create<TModel>(string username, string password);
        //User Create(string username, string password);
        void Delete(int id);



    }
}
