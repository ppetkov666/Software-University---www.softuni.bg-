namespace Forum.Services
{
    using Forum.Data;
    using Forum.Models;
    using Forum.Services.Contracts;
    using System.Linq;

    public class CategoryService : ICategoryService
    {

        private readonly ForumDbContext context;
        public CategoryService(ForumDbContext context)
        {
            this.context = context;
        }

        public Category ByName(string name)
        {
            Category category = context.Categories.SingleOrDefault(c => c.Name == name);
            return category;
        }

        public Category Create(string name)
        {
            Category category = new Category
            {
                Name = name
            };
            context.Categories.Add(category);
            context.SaveChanges();
            return category;
        }
    }
}
