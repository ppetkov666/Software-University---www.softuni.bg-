namespace External_Format_Processing_demo.Data.Models
{
    using System.Collections.Generic;
    public class Manifacturer
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<Product> Products { get; set; }

    }
}
