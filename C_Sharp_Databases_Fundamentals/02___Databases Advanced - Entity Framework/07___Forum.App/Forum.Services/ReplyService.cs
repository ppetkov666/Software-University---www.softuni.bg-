namespace Forum.Services
{
    using Forum.Data;
    using Forum.Models;
    using Forum.Services.Contracts;
    using System.Linq;

    public class ReplyService : IReplyService
    {

        private readonly ForumDbContext context;
        public ReplyService(ForumDbContext context)
        {
            this.context = context;
        }

        public Reply Create(string replyText, int postId, int authorId)
        {
            Reply reply = new Reply
            {
                Content = replyText,
                PostId = postId,
                AuthorId = authorId
            };
            context.Replies.Add(reply);
            context.SaveChanges();
            return reply;
        }

        public void Delete(int replyId)
        {
            Reply replyToDelete = context.Replies.SingleOrDefault(r => r.Id == replyId);
            if (replyToDelete != null)
            {
                context.Replies.Remove(replyToDelete);
                context.SaveChanges();
            }
        }
    }
}
