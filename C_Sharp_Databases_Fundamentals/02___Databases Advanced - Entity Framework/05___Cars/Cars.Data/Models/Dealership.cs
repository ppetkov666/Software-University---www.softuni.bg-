using System.Collections.Generic;

namespace Cars.Data.Models
{
    public class Dealership
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<CarDealership> CarDealerships { get; set; } = new List<CarDealership>();

    }
}
