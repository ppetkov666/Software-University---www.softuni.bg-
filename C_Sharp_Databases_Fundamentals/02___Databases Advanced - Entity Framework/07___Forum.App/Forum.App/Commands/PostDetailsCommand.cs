namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using Forum.Models;
    using Forum.Services.Contracts;
    using System.Text;

    public class PostDetailsCommand : ICommand
    {
        private readonly IPostService postService;

        public PostDetailsCommand(IPostService postService)
        {
            this.postService = postService;
        }

        public string Execute(params string[] arguments)
        {
            int postId = int.Parse(arguments[0]);

            Post post = postService.ById(postId);

            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"{post.Title} by {post.Author.UserName}");
            foreach (Reply reply in post.Replies)
            {
                sb.AppendLine($"    {reply.Content}  by {reply.Author.UserName}");
            }
            
            return sb.ToString();
        }
    }
}
