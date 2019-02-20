namespace Many_to_Many_releations
{
    public class StartUp
    {
        public static void Main(string[] args)
        {
            using (MyDbContext db = new MyDbContext())
            {
                db.Database.EnsureDeleted();
                db.Database.EnsureCreated();
            }
        }
    }
}
