using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Cars.Data.Models.Configurations
{
    public class EngineConfiguration : IEntityTypeConfiguration<Engine>
    {
        public void Configure(EntityTypeBuilder<Engine> builder)
        {
            builder
                .HasMany(e => e.Cars)
                .WithOne(c => c.Engine)
                .HasForeignKey(e => e.EngineId);
        }
    }
}
