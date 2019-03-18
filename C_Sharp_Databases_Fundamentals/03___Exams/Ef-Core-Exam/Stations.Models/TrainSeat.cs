﻿namespace Stations.Models
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

    }
}