namespace External_Format_Processing_demo.Data
{
    using External_Format_Processing_demo.Data.Models;
    using Microsoft.EntityFrameworkCore;
    public class ProductsDbContext : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder builder)
        {
            base.OnConfiguring(builder);
            if (!builder.IsConfigured)
            {
                builder.UseSqlServer(@"Server=the_myth_3014\SQLEXPRESS;Database=Employee_EF_Core;Integrated Security=True");
            }
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            builder.Entity<ProductWarehouse>()
                .HasKey(k => new { k.ProductId, k.WarehouseId });

            builder.Entity<Product>()
                .HasMany(p => p.ProductWarehouses)
                .WithOne(pw => pw.Product)
                .HasForeignKey(pw => pw.ProductId);

            builder.Entity<Warehouse>()
                .HasMany(w => w.ProductWarehouses)
                .WithOne(pw => pw.Warehouse)
                .HasForeignKey(pw => pw.WarehouseId);

            builder.Entity<Manifacturer>()
               .HasMany(m => m.Products)
               .WithOne(p => p.Manifacturer)
               .HasForeignKey(p => p.ManifacturerId);
        }
    }
}
