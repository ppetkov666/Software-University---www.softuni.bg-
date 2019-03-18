namespace External_Format_Processing_demo.Data.Models
{
    using Newtonsoft.Json;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;

    public class Product
    {
        //[JsonIgnore]
        public int Id { get; set; }
        [Required]
        public string Name { get; set; }
        public string Description { get; set; }
        //[JsonIgnore]
        public int ManifacturerId { get; set; }
        public Manifacturer Manifacturer { get; set; }
        public ICollection<ProductWarehouse> ProductWarehouses { get; set; }

    }
}
