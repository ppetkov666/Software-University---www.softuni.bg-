namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
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
            var posts = postService.All().GroupBy(p=>p.Category).ToArray();
            StringBuilder sb = new StringBuilder();
            foreach (IGrouping<Category,Post> postbyGroup in posts)
            {
                string categoryName = postbyGroup.Key.Name;
                sb.AppendLine($"{categoryName}: ");
                foreach (var post in postbyGroup)
                {
                    sb.AppendLine($"-{post.Id}.{post.Title} - {post.Content} by {post.Author.UserName}");
                }
            }
            return sb.ToString();
        }
    }
}
