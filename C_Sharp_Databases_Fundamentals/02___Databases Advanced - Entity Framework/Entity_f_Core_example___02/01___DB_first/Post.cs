using System;
using System.Collections.Generic;

namespace _01___DB_first
{
    public partial class Post
    {
        public Post()
        {
            Comments = new HashSet<Comments>();
        }

        public int PostId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }

        public virtual User User { get; set; }
        public virtual ICollection<Comments> Comments { get; set; }
    }
}
