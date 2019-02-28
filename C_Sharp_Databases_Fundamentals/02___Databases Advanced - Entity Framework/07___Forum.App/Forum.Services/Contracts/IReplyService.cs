namespace Forum.Services.Contracts
{
    using Forum.Models;
    public interface IReplyService
    {
        TModel Create<TModel>(string replyText, int postId, int authorId);
        //Reply Create(string replyText, int postId, int authorId);
        void Delete(int replyId); 
    }
}
