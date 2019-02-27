namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using Forum.Models;
    using Forum.Services.Contracts;

    public class CreatePostCommand : ICommand
    {
        private readonly IPostService postService;
        private readonly ICategoryService categoryService;

        public CreatePostCommand(IPostService postService, ICategoryService categoryService)
        {
            this.postService = postService;
            this.categoryService = categoryService;

        }
        public string Execute(params string[] arguments)
        {
            string categoryName = arguments[0];
            string postTitle = arguments[1];
            string postContent = arguments[2];

            if (Session.User == null)
            {
                return "You are not logged in!"; 
            }

            Category category = categoryService.ByName(categoryName);
            if (category == null)
            {
                category = categoryService.Create(categoryName);
            }

            int authorId = Session.User.Id;
            int categoryId = category.Id;
            Post post = postService.Create(postTitle, postContent, categoryId, authorId);

            return $"Post with id {post.Id} created successfully!";
        }
    }
}
