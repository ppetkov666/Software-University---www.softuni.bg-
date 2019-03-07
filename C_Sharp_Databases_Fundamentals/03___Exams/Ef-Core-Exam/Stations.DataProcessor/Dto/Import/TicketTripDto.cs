namespace Stations.DataProcessor.Dto.Import
{
    using System;
    using System.ComponentModel.DataAnnotations;
    using System.Xml.Serialization;

    [XmlType("Trip")]
    public class TicketTripDto
    {
        [Required]
        public string OriginStation { get; set; }

        [Required]
        public string DestinationStation { get; set; }

        [Required]
        public string DepartureTime { get; set; }

    }
}
