namespace Forum.App.Commands
{
    using Forum.App.Commands.Contracts;
    using Forum.App.Models;
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

            CategoryDto category = categoryService.ByName<CategoryDto>(categoryName);
            if (category == null)
            {
                category = categoryService.Create<CategoryDto>(categoryName);
            }

            int authorId = Session.User.Id;
            int categoryId = category.Id;
            PostDto post = postService.Create<PostDto>(postTitle, postContent, categoryId, authorId);

            return $"Post with id {post.Id} created successfully!";
        }
    }
}
