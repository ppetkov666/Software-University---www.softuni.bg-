using Stations.Models.Enums;
using System.ComponentModel.DataAnnotations;

namespace Stations.DataProcessor.Dto.Import
{
    public class TrainDto
    {
        [Required]
        [MaxLength(10)]
        public string TrainNumber { get; set; }

        // this is because by condition if Type is null default value must be HighSpeed
        public string Type { get; set; } = "HighSpeed";

        public SeatDto[] Seats { get; set; } = new SeatDto[0];
    }
}
 