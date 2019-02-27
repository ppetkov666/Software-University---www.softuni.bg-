namespace Forum.Services.Contracts
{
    using Forum.Models;
    public interface ICategoryService
    {
        Category ByName(string name);
        Category Create(string name);
    }
}
