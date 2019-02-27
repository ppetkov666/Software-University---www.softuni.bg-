namespace Forum.Services.Contracts
{
    using Forum.Models;
    public interface IReplyService
    {
        Reply Create(string replyText, int postId, int authorId);
        void Delete(int replyId); 
    }
}
