using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;

namespace TerraON.Infrastructure.DataAccess
{
    public class TerraONDbContext(DbContextOptions options) : DbContext(options)
    {
        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            ConfigureUser(modelBuilder);
        }

        private static void ConfigureUser(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().ToTable("Users");
        }
    }
}
