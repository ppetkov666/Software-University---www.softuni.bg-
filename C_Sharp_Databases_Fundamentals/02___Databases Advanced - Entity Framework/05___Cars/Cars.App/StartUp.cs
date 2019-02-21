namespace Cars.App
{
    using Cars.Data;
    using Cars.Data.Models;
    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Linq;
    using System.Text;

    public class StartUp
    {
        public static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            // this approach is when i dont want to use default connection string
            //DbContextOptionsBuilder optionsBuilder = new DbContextOptionsBuilder();
            //optionsBuilder.UseSqlServer(@"Server=EXAMPLE;Database=EXAMPLE;Integrated Security=True;");
            //CarsDbContext context = new CarsDbContext(optionsBuilder.Options);
            CarsDbContext context = new CarsDbContext();
            //ResetDatabase(context);
            // for example purpose i added plate number manualy from db with update statement
            // and also will add another record from visual studio is it follows
            LicensePlate[] plates = context.LicensePlate.ToArray();

            Car[] cars = context
                .Cars
                .Include(c => c.Engine)
                .Include(c => c.Make)
                .Include(c => c.LicensePlate)
                .Include(c => c.CarDealerships)
                .ThenInclude(cd => cd.Dealership)
                .OrderBy(c => c.ProductionYear)
                .ToArray();


            cars[2].LicensePlate = plates.SingleOrDefault(n => n.Id == 1);
            foreach (Car car in cars)
            {
                string licensePlate = car.LicensePlate != null ? car.LicensePlate.Number : "No license Plate";
                Console.WriteLine($"{car.Make.Name} {car.Model} - fueltype: {car.Engine.FuelType} - {licensePlate}");
            }

            //var cars = context
            //    .Cars
            //    .Select(c => new
            //    {
            //        Engine = c.Engine.FuelType,
            //        LicensePlate = c.LicensePlate.Number,
            //        Make = c.Make.Name,
            //        Model = c.Model
            //    }).ToArray();

            //foreach (var car in cars)
            //{
            //    string licensePlate = car.LicensePlate != null ? car.LicensePlate : "No license Plate";
            //    Console.WriteLine($"{car.Make} {car.Model} - fueltype: {car.Engine} - {licensePlate}");
            //}

        }
        public static void ResetDatabase(CarsDbContext context)
        {
            context.Database.EnsureDeleted();

            context.Database.Migrate();
            Seed(context);
        }

        private static void Seed(CarsDbContext context)
        {
            Make[] makes = new[]
            {
                new Make{ Name = "Bmw"},
                new Make{ Name = "Mercedes"},
                new Make{ Name = "Audi"},
                new Make{ Name = "VW"},
            };

            Engine[] engines = new[]
            {
                new Engine
                {
                    Capacity = 2.0,
                    Cyllinders = 4,
                    FuelType = FuelType.Petrol,
                    HorsePower = 150,
                },
                new Engine
                {
                    Capacity = 3.0,
                    Cyllinders = 6,
                    FuelType = FuelType.Electric,
                    HorsePower = 250,
                },
                new Engine
                {
                    Capacity = 3.5,
                    Cyllinders = 8,
                    FuelType = FuelType.Diesel,
                    HorsePower = 350,
                }
            };

            Car[] cars = new[]
            {
                new Car
                {
                    Engine = engines[0],
                    Make = makes[3],
                    Doors = 4,
                    Model = "Polo",
                    ProductionYear = new DateTime(2008),
                    Transmission = Transmission.Automatic,
                },
                new Car
                {
                    Engine = engines[1],
                    Make = makes[1],
                    Doors = 2,
                    Model = "C - 300 ",
                    ProductionYear = new DateTime(2012),
                    Transmission = Transmission.Automatic,
                },
                new Car
                {
                    Engine = engines[2],
                    Make = makes[0],
                    Doors = 2,
                    Model = "3 series",
                    ProductionYear = new DateTime(2018),
                    Transmission = Transmission.Manual,
                }
            };
            context.Cars.AddRange(cars);

            Dealership[] dealerships = new[]
            {
                new Dealership{ Name = "PetkoCarAUTO"},
                new Dealership{ Name = "MobileAutoHouse"}
            };
            context.Dealerships.AddRange(dealerships);

            CarDealership[] carDealerships = new []
            {
                new CarDealership{Car = cars[0],Dealership = dealerships[0]},
                new CarDealership{Car = cars[1],Dealership = dealerships[1]},
                new CarDealership{Car = cars[0],Dealership = dealerships[1]}

            };
            context.CarDealerships.AddRange(carDealerships);
             
            LicensePlate[] licensePlates = new[]
            {
                new LicensePlate{ Number = "СТ5500АВ"},
                new LicensePlate{ Number = "СО5210НЕ"},
                new LicensePlate{ Number = "С1130БЕ"}
            };
            context.LicensePlate.AddRange(licensePlates);
            context.SaveChanges();
        }
    }
}
