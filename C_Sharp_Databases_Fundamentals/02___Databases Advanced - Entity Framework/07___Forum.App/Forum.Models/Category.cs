namespace Forum.Models
{
    using System.Collections;
    using System.Collections.Generic;

    public class Category
    {
        public Category()
        {

        }
        public Category(string categoryName)
        {
            this.Name = categoryName;
        }

        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<Post> Posts { get; set; }

    }
}
