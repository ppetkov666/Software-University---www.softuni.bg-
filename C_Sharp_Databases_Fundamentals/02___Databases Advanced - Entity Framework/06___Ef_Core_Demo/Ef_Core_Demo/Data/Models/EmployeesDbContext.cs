using Microsoft.EntityFrameworkCore;

namespace Ef_Core_Demo.Data.Models
{
    public class EmployeesDbContext : DbContext
    {
        public DbSet<Employee> Employees { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder builder)
        {
            base.OnConfiguring(builder);
            if (!builder.IsConfigured)
            {
                builder.UseSqlServer(@"Server=the_myth_3014\SQLEXPRESS;Database=Employee_EF_Core;Integrated Security=True");
            }
        }
        
    }
}
