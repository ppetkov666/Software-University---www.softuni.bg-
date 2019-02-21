namespace One_to_Many_example_Entity_F_core_
{
    using Microsoft.EntityFrameworkCore;
    
    public class MyDbContext : DbContext
    {
        public DbSet<Employee> Employees { get; set; }
        public DbSet<Department> Departments { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder builder)
        {
            builder.UseSqlServer("Server=DESKTOP-FCG26GG\\SQLEXPRESS;Database=OneToManyDB;Integrated Security=True;");
            base.OnConfiguring(builder);
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<Employee>()
                .HasOne(e => e.Department)
                .WithMany(d => d.Employees)
                .HasForeignKey(e=>e.DepartmentId);

            builder.Entity<Employee>()
                .HasOne(e => e.Manager)
                .WithMany(m => m.Workers)
                .HasForeignKey(e => e.ManagerId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
