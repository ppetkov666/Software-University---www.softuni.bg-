using Forum.Data;
using Microsoft.EntityFrameworkCore;

namespace Forum.Services.Contracts
{
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
