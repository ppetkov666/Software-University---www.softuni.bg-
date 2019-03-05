namespace Stations.Models
{
    using System.ComponentModel.DataAnnotations;
    public class TrainSeat
    {
        public int Id { get; set; }

        public int TrainId { get; set; }

        [Required]
        public Train Train { get; set; }

        [Required]
        public int SeatingClassId { get; set; }
        public SeatingClass SeatingClass { get; set; }

        [Required]
        [Range(0, int.MaxValue)]
        public int Quantity { get; set; }

        // this is the other way if the value type is decimal - to be non negative value
        //[Range(typeof(decimal), "0", "79228162514264337593543950335")]
        //public decimal QuantityDecimal { get; set; }


    }
}