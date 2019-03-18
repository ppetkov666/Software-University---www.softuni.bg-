namespace Forum.App.Commands
{
    using AutoMapper.QueryableExtensions;
    using Forum.App.Commands.Contracts;
    using Forum.App.Models;
    using Forum.Models;
    using Forum.Services.Contracts;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    
    public class ListPostsCommand : ICommand
    {
        private readonly IPostService postService;
        public ListPostsCommand(IPostService postService)
        {
            this.postService = postService;
        }
        public string Execute(params string[] arguments)
        {
            
            IGrouping<string, PostDto>[] posts = postService
                .All<PostDto>()
                .GroupBy(p=>p.CategoryName)
                .ToArray();
            StringBuilder sb = new StringBuilder();
            foreach (var postbyGroup in posts)
            {
                string categoryName = postbyGroup.Key;
                sb.AppendLine($"{categoryName}: ");
                foreach (var post in postbyGroup)
                {
                    sb.AppendLine($"-{post.Id}.{post.Title} - {post.Content} by {post.AuthorUsername}");
                }
            }
            return sb.ToString();
        }
    }
}
