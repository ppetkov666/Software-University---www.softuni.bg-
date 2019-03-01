using System.Collections.Generic;

namespace External_Format_Processing_demo.Data.Models
{
    public class Warehouse
    {
        public int Id { get; set; }
        public string Location { get; set; }
        public ICollection<ProductWarehouse> ProductWarehouses { get; set; }

    }
}
