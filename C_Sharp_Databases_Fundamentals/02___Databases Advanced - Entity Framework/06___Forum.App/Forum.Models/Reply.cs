namespace Forum.Models
{
    public class Reply
    {
        public Reply()
        {

        }
        public Reply(string content, User author, Post post)
        {
            this.Content = content;
            this.Author = author;
            this.Post = post;
        }

        public Reply(string content, int authorId, int postId)
        {
            this.Content = content;
            this.AuthorId = authorId;
            this.PostId = postId;
        }
        public int Id { get; set; }
        public string Content { get; set; }
        public int AuthorId { get; set; }
        public User Author { get; set; }
        public int PostId { get; set; }
        public Post Post { get; set; }


    }
}
