namespace Forum.Services.Contracts
{
    using Forum.Models;
    using System.Collections.Generic;
    using System.Linq;

    public interface IPostService
    {
        TModel Create<TModel>(string title, string content, int categoryId, int authorId);
        //Post Create(string title, string content, int categoryId, int authorId);
        TModel ById<TModel>(int postId);
        //Post ById(int postId);
        IQueryable<TModel> All<TModel>();
        
    }
}
