namespace ForumCode_First
{
    using ForumCode_First.Data;
    using ForumCode_First.Data.Models;
    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Linq;
    using System.Text;

    public class StartUp
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            ForumDbContext context = new ForumDbContext();

            
            ResetDataBase(context);

            var categoriesV2 = context
                .Categories
                .Select(c => new
                {
                    name = c.Name,
                    posts = c.Posts.Select(p => new
                    {
                        title = p.Title,
                        content = p.Content,
                        authorusername = p.Author.UserName,
                        replies = p.Replies.Select(r => new
                        {
                            content = r.Content,
                            authorusername = p.Author.UserName,

                        }),
                        Tags = p.PostTags.Select(t=>t.Tag.Name)
                        
                    })
                }).ToArray();

            foreach (var category in categoriesV2)
            {
                Console.WriteLine($"{category.name} category has {category.posts.Count()} post");
                foreach (var post in category.posts)
                {
                    Console.WriteLine($"--{post.title}: {post.content}");
                    Console.WriteLine($"by {post.authorusername}");

                    Console.WriteLine("Tags: " + string.Join(",", post.Tags));
                    foreach (var reply in post.replies)
                    {
                        Console.WriteLine($"reply: author: {reply.authorusername}: {reply.content}");
                        
                    }
                    Console.WriteLine();
                }
            }

            //var categories = context
            //    .Categories
            //    .Include(c => c.Posts)
            //    .ThenInclude(p => p.Author)
            //    .ThenInclude(r=>r.Replies);
            //foreach (Category category in categories)
            //{
            //    Console.WriteLine($"{category.Name} category has {category.Posts.Count} post");
            //    foreach (var post in category.Posts)
            //    {
            //        Console.WriteLine($"--{post.Title}: {post.Content}");
            //        Console.WriteLine($"by {post.Author.UserName}");
            //        foreach (var reply in post.Replies)
            //        {
            //            Console.WriteLine("Reply:");
            //            Console.WriteLine($"author: {reply.Author.UserName}: {reply.Content}");
            //        }
            //    }
            //}
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

            var tags = new[]
            {
                new Tag{Name="C#"},
                new Tag{Name="Java"},
                new Tag{Name="Microsoft"},
                new Tag{Name="Google"},
            };

            PostTag[] postTags = new[]
            {
                new PostTag(){ PostId = 1, Tag = tags[0]},
                new PostTag(){ PostId = 1, Tag = tags[1]},
                new PostTag(){ PostId = 1, Tag = tags[2]},
                new PostTag(){ PostId = 1, Tag = tags[3]},
            };

            context.PostsTags.AddRange(postTags);

            context.SaveChanges();

        }
    }
}
