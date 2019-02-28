namespace Forum.Services
{
    using AutoMapper;
    using AutoMapper.QueryableExtensions;
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

        public TModel ByName<TModel>(string name)
        {
            TModel category = context
                .Categories
                .Where(c => c.Name == name)
                .ProjectTo<TModel>()
                .SingleOrDefault();

            return category;
        }

        //public Category ByName(string name)
        //{
        //    Category category = context.Categories.SingleOrDefault(c => c.Name == name);
        //    return category;
        //}

        public TModel Create<TModel>(string name)
        {
            Category category = new Category
            {
                Name = name
            };
            context.Categories.Add(category);
            context.SaveChanges();

            TModel dto = Mapper.Map<TModel>(category);
            return dto;
        }

        //public Category Create(string name)
        //{
        //    Category category = new Category
        //    {
        //        Name = name
        //    };
        //    context.Categories.Add(category);
        //    context.SaveChanges();
        //    return category;
        //}
    }
}
