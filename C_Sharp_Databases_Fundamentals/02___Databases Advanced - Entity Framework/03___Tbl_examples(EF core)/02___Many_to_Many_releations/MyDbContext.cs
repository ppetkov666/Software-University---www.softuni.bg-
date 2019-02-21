namespace Many_to_Many_releations
{
    using Microsoft.EntityFrameworkCore;
    public class MyDbContext : DbContext
    {
        public DbSet<Course> Courses { get; set; }
        public DbSet<Student> Students { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder builder)
        {
            builder.UseSqlServer("Server=DESKTOP-FCG26GG\\SQLEXPRESS;Database=ManyToManyDB;Integrated Security=True;");
            base.OnConfiguring(builder);
        }
       
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<StudentCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });

            builder.Entity<Student>()
                .HasMany(s => s.Courses)
                .WithOne(sc => sc.Student)
                .HasForeignKey(sc => sc.StudentId);

            builder.Entity<Course>()
                .HasMany(c => c.Students)
                .WithOne(sc => sc.Course)
                .HasForeignKey(sc => sc.CourseId);
        }
    }
}
