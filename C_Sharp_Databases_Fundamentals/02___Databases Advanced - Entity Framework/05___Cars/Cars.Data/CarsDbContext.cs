namespace Cars.Data
{
    using Cars.Data.Models;
    using Cars.Data.Models.CarConfiguration;
    using Cars.Data.Models.Configurations;
    using Microsoft.EntityFrameworkCore;
    public class CarsDbContext : DbContext
    {
        public CarsDbContext()
        {

        }
        public CarsDbContext(DbContextOptions options)
            :base(options)
        {

        }

        public DbSet<Make> Makes { get; set; }
        public DbSet<Car> Cars { get; set; }
        public DbSet<Engine> Engines { get; set; }
        public DbSet<LicensePlate> LicensePlate { get; set; }
        public DbSet<Dealership> Dealerships { get; set; }
        public DbSet<CarDealership> CarDealerships { get; set; }


        protected override void OnConfiguring(DbContextOptionsBuilder builder)
        {
            base.OnConfiguring(builder);

            if (!builder.IsConfigured)
            {
                builder.UseSqlServer(@"Server=the_myth_3014\SQLEXPRESS;Database=Cars;Integrated Security=True;");
            }
        }
        
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.ApplyConfiguration(new EngineConfiguration());
            builder.ApplyConfiguration(new CarConfiguration());
            builder.ApplyConfiguration(new CarDealershipConfiguration());

        }
    }
}
