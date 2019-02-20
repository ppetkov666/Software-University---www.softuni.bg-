using System;
using System.Collections.Generic;

namespace _01___DB_first
{
    public partial class User
    {
        public User()
        {
            Comments = new HashSet<Comments>();
            Posts = new HashSet<Post>();
        }

        public int UserId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<Comments> Comments { get; set; }
        public virtual ICollection<Post> Posts { get; set; }
    }
}
