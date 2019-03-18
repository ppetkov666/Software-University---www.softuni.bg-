namespace Forum.Services
{
    using System.Collections.Generic;
    using System.Linq;
    using AutoMapper;
    using AutoMapper.QueryableExtensions;
    using Forum.Data;
    using Forum.Models;
    using Forum.Services.Contracts;
    using Microsoft.EntityFrameworkCore;

    public class PostService : IPostService
    {
        private readonly ForumDbContext context;
        public PostService(ForumDbContext context)
        {
            this.context = context;
        }
        // is a generic type - i expect T and Model just specify what is T , in this case is a Model
        // is can be TSomething ... and it will work also 
        public IQueryable<TModel> All<TModel>()
        {
            //var posts = context
            //    .Posts
            //    .Include(p => p.Author)
            //    .Include(p => p.Category)
            //    .ToArray();
            // this is how we can map collection to collection with ProjectTo method
            IQueryable<TModel> posts = context
                .Posts
                .ProjectTo<TModel>();                
            return posts;
        }

        public TModel ById<TModel>(int postId)
        {
            TModel post = context
                .Posts
                .Where(p => p.Id == postId)
                .ProjectTo<TModel>()
                .SingleOrDefault();

            return post;
        }

        //public Post ById(int postId)
        //{
        //    Post post = context
        //        .Posts
        //        .Include(p=>p.Author)
        //        .Include(p => p.Replies)
        //        .ThenInclude(r => r.Author)
        //        .SingleOrDefault(p=>p.Id == postId);

        //    return post;
        //}


        public TModel Create<TModel>(string title, string content, int categoryId, int authorId)
        {
            Post post = new Post
            {
                Title = title,
                Content = content,
                CategoryId = categoryId,
                AuthorId = authorId
            };

            context.Posts.Add(post);
            context.SaveChanges();

            TModel dto = Mapper.Map<TModel>(post);
            return dto;
        }

        //public Post Create(string title, string content, int categoryId, int authorId)
        //{
        //    var post = new Post
        //    {
        //        Title = title,
        //        Content = content,
        //        CategoryId = categoryId,
        //        AuthorId = authorId
        //    };

        //    context.Posts.Add(post);
        //    context.SaveChanges();
        //    return post;
        //}
    }
}
