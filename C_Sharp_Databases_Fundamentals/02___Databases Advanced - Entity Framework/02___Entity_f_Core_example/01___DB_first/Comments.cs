using System;
using System.Collections.Generic;

namespace _01___DB_first
{
    public partial class Comments
    {
        public int CommentId { get; set; }
        public int UserId { get; set; }
        public int PostId { get; set; }
        public string Content { get; set; }

        public virtual Post Post { get; set; }
        public virtual User User { get; set; }
    }
}
