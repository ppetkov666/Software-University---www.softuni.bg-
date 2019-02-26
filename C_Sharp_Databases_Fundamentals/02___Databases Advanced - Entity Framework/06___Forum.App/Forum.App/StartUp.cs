namespace Forum.App
{
    using Forum.Data;
    using Forum.Models;
    using Forum.Services;
    using Forum.Services.Contracts;
    using Microsoft.EntityFrameworkCore;
    using Microsoft.Extensions.DependencyInjection;
    using System;
    using System.Text;

    public class StartUp
    {
        static void Main(string[] args)
        {
            
        }

        private static IServiceProvider ConfigureServices()
        {

            ServiceCollection serviceCollection = new ServiceCollection();

            serviceCollection.AddDbContext<ForumDbContext>(options =>
            options.UseSqlServer(Configuration.ConnectionString));

            serviceCollection.AddTransient<IUserService, UserService>();
            serviceCollection.AddTransient<IDataBaseInitializerService, DatabaseInitialzerService>();


            ServiceProvider serviceProvider = serviceCollection.BuildServiceProvider();
            return serviceProvider;
        }

        private static void ResetDataBase(ForumDbContext context)
        {
            context.Database.EnsureDeleted();

            // this method is dangerous because if we have migrations they will not work
            //context.Database.EnsureCreated();

            // it creates db and set the migrations
            context.Database.Migrate();
            Seed(context);


        }

        private static void Seed(ForumDbContext context)
        {
            User[] users = new[]
            {
                new User("petko", "123"),
                new User("ivan", "1234"),
                new User("jeko", "12345"),
                new User("kaloyan", "123456")
            };
            context.Users.AddRange(users);

            Category[] categories = new[]
            {
                new Category("c#"),
                new Category("java"),
                new Category("python"),
                new Category("kotlin"),
            };
            context.Categories.AddRange(categories);

            Post[] posts = new[]
            {
                new Post("c# rools","this are c# rools", categories[0], users[0]),
                new Post("java rools","java rools са много строги", categories[1], users[1]),
                new Post("python rools","this are python правила", categories[2], users[2]),

            };
            context.Posts.AddRange(posts);

            Reply[] replies = new[]
            {
                new Reply("i dont like Python rools",users[0], posts[2]),
                new Reply("c# has the best rools",users[1], posts[0]),
                new Reply("java rools are not bad",users[2], posts[1]),

            };
            context.Replies.AddRange(replies);


            context.SaveChanges();

        }
    }
}
