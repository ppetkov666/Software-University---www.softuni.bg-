namespace ForumCode_First.Data.Models
{
    using System;
    using System.Collections.Generic;
    using System.Text;

    public class User
    {
        public User()
        {

        }
        public User(string userName, string password)
        {
            this.UserName = userName;
            this.Password = password;
        }
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public ICollection<Post> Posts { get; set; } = new List<Post>();
        public ICollection<Reply> Replies { get; set; } = new List<Reply>();

    }
}
