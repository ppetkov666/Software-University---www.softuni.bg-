namespace Cars.Data.Models
{
    using System;
    using System.Collections.Generic;

    public class Car
    {
        public int Id { get; set; }
        public int MakeId { get; set; }
        public Make Make { get; set; }
        public string Model { get; set; }
        public int EngineId { get; set; }
        public Engine Engine { get; set; }
        public int Doors { get; set; }        
        public Transmission Transmission { get; set; }
        public DateTime ProductionYear { get; set; }
        public int? LicensePlateId { get; set; }
        public LicensePlate LicensePlate { get; set; }
        public ICollection<CarDealership> CarDealerships { get; set; } = new List<CarDealership>();

        // just for demonstration if we have employee and manager and because this manager is also employee it looks like this:
        // public int ManagerId {get;set;}
        // public Employee Manager {get;set;}
        // this is self referencing it looks like recursive

    }
}
