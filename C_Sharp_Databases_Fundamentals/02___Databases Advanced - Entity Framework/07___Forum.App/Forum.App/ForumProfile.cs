namespace Forum.App
{
    using AutoMapper;
    using Forum.App.Models;
    using Forum.Models;

    // we inherit Profile class who is part of AutoMapper
    public class ForumProfile : Profile
    {
        public ForumProfile()
        {
            CreateMap<Post, PostDetailsDto>()
                .ForMember(dto => dto.ReplyCount,
                             c => c.MapFrom(post => post.Replies.Count));
            CreateMap<Reply, ReplyDto>();
            CreateMap<User, User>();
        }
    }
}
