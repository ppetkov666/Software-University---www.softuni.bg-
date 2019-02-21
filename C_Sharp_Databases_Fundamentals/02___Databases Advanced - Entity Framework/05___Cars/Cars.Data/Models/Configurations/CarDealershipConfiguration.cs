

namespace Cars.Data.Models.Configurations
{
    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

    public class CarDealershipConfiguration : IEntityTypeConfiguration<CarDealership>
    {
        // many to many - we use the middle the common table CarDealership. One can can be in many dealerships and we access it 
        // from CarDealership.Dealership and the other is on the same principle
        public void Configure(EntityTypeBuilder<CarDealership> builder)
        {
            builder
                .HasKey(cd => new { cd.CarId, cd.DealershipId });
            builder
                .ToTable("CarsDealerships");

            builder
                .HasOne(cd => cd.Car)
                .WithMany(c => c.CarDealerships)
                .HasForeignKey(cd => cd.CarId);

            builder
                .HasOne(cd => cd.Dealership)
                .WithMany(d => d.CarDealerships)
                .HasForeignKey(cd => cd.DealershipId);
        }
    }
}
