namespace Forum.Services.Contracts
{
    using Forum.Models;
    using System.Collections.Generic;

    public interface IPostService
    {
        Post Create(string title, string content, int categoryId, int authorId);
        Post ById(int postId);
        IEnumerable<Post> All();
        
    }
}
