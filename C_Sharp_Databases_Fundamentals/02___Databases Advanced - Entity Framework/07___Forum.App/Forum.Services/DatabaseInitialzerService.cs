namespace Forum.Services
{
    using Forum.Data;
    using Forum.Services.Contracts;
    using Microsoft.EntityFrameworkCore;
    public class DatabaseInitialzerService : IDataBaseInitializerService
    {
        private readonly ForumDbContext context;

        public DatabaseInitialzerService(ForumDbContext context)
        {
            this.context = context;
        }
        public void InitializeDatabase()
        {
            context.Database.Migrate(); 
        }
    }
}
