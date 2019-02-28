namespace Forum.App.Commands
{
    using AutoMapper;
    using Forum.App.Commands.Contracts;
    using Forum.App.Models;
    using Forum.Models;
    using Forum.Services.Contracts;
    using System.Linq;
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

            PostDetailsDto post = postService.ById<PostDetailsDto>(postId);

            // using automapper and mapping object to object
            //PostDetailsDto post = Mapper.Map<PostDetailsDto>(post);
            //done "by hand"
            //PostDetailsDto postDetailsDto = new PostDetailsDto()
            //{
            //    Id = post.Id,
            //    Title = post.Title,
            //    Content = post.Content,
            //    AuthorUsername = post.Author.UserName,
            //    Replies = post.Replies.Select(r=>new ReplyDto
            //    {
            //        Content = r.Content,
            //        AuthorUsername = r.Author.UserName,
            //    })
            //};

            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"Post: {post.Title} by {post.AuthorUsername}");
            foreach (var reply in post.Replies)
            {
                sb.AppendLine($"    Reply: {reply.Content} by {reply.AuthorUsername}");
            }
            
            return sb.ToString();
        }
    }
}
