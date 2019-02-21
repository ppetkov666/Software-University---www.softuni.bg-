using System.Collections.Generic;

namespace Cars.Data.Models
{
    public class Engine
    {
        public int Id { get; set; }        
        public double Capacity { get; set; }
        public FuelType FuelType { get; set; }
        public double Cyllinders { get; set; }
        public int HorsePower { get; set; }
        public ICollection<Car> Cars { get; set; }


    }
}