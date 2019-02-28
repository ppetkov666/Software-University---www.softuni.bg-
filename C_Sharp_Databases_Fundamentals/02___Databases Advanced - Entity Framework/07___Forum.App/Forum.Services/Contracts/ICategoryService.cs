namespace Forum.Services.Contracts
{
    using Forum.Models;
    public interface ICategoryService
    {
        TModel ByName<TModel>(string name);
        //Category ByName(string name);
        TModel Create<TModel>(string name);
        //Category Create(string name);
    }
}
