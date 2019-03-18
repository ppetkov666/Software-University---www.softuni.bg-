using System.ComponentModel.DataAnnotations;

namespace Ef_Core_Demo.Data.Models
{
    public class Employee
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; }
        [Required]
        [MaxLength(50)]
        public string LastName { get; set; }

        [ConcurrencyCheck]
        public decimal Salary { get; set; }

        public override string ToString()
        {
            return $"{this.FirstName} {this.LastName} with salary: {this.Salary}";
        }
    }
}
