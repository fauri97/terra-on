using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using TerraON.Domain.Entities;

namespace TerraON.Infrastructure.DataAccess
{
    public class TerraONDbContext(DbContextOptions options) : DbContext(options)
    {
        public DbSet<User> Users { get; set; }
        public DbSet<Report> Reports { get; set; }
        public DbSet<Image> Images { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Like> Likes { get; set; }
        public DbSet<ReportPost> ReportPosts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            ConfigureUser(modelBuilder);
            ConfigureReport(modelBuilder);
            ConfigureImage(modelBuilder);
            ConfigureComment(modelBuilder);
            ConfigureLike(modelBuilder);
            ConfigureReportPost(modelBuilder);

            var dtConverter = new ValueConverter<DateTime, DateTime>(
                v => v.Kind == DateTimeKind.Utc ? v : v.ToUniversalTime(),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

            var ndtConverter = new ValueConverter<DateTime?, DateTime?>(
                v => v.HasValue ? (v.Value.Kind == DateTimeKind.Utc ? v : v.Value.ToUniversalTime()) : v,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v);

            foreach (var entity in modelBuilder.Model.GetEntityTypes())
            {
                foreach (var prop in entity.GetProperties())
                {
                    if (prop.ClrType == typeof(DateTime))
                    {
                        prop.SetValueConverter(dtConverter);
                        prop.SetColumnType("timestamp with time zone");
                    }
                    else if (prop.ClrType == typeof(DateTime?))
                    {
                        prop.SetValueConverter(ndtConverter);
                        prop.SetColumnType("timestamp with time zone");
                    }
                }
            }

            base.OnModelCreating(modelBuilder);
        }

        private static void ConfigureReportPost(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<ReportPost>();
            e.ToTable("ReportPosts");
            e.HasKey(rp => rp.Id);
            e.Property(rp => rp.UserId)
                .IsRequired();
            e.Property(rp => rp.ReportId)
                .IsRequired();

            e.HasOne(rp => rp.User)
                .WithMany()
                .HasForeignKey(rp => rp.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }

        private static void ConfigureUser(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().ToTable("Users");

            modelBuilder.Entity<User>()
                .HasOne(u => u.ProfileImage)
                .WithOne(i => i.User)
                .HasForeignKey<User>(u => u.ProfileImageId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private static void ConfigureReport(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Report>();
            e.ToTable("Reports");

            e.HasKey(r => r.Id);

            e.Property(r => r.AuthorId)
                .IsRequired();

            // Relacionamentos
            e.HasOne(r => r.Author)
                .WithMany()
                .HasForeignKey(r => r.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);

            e.HasMany(r => r.Images)
             .WithOne(i => i.Report)
             .HasForeignKey(i => i.ReportId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasMany(r => r.Comments)
             .WithOne(c => c.Report)
             .HasForeignKey(c => c.ReportId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasMany(r => r.Likes)
             .WithOne(l => l.Report)
             .HasForeignKey(l => l.ReportId)
             .OnDelete(DeleteBehavior.Cascade);
        }

        private static void ConfigureImage(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Image>();
            e.ToTable("Images");

            e.HasOne(i => i.Report)
             .WithMany(r => r.Images)
             .HasForeignKey(i => i.ReportId)
             .OnDelete(DeleteBehavior.Cascade);

            e.Ignore(i => i.User);
        }

        private static void ConfigureComment(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Comment>();
            e.ToTable("Comments");

            // Relacionamentos
            e.HasOne(r => r.Author)
             .WithMany()
             .HasForeignKey(c => c.AuthorId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(c => c.Report)
             .WithMany(r => r.Comments)
             .HasForeignKey(c => c.ReportId)
             .OnDelete(DeleteBehavior.Cascade);
        }

        private static void ConfigureLike(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Like>();
            e.ToTable("Likes");

            e.HasKey(l => new { l.UserId, l.ReportId });

            e.HasOne(l => l.User)
             .WithMany()
             .HasForeignKey(l => l.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasOne(l => l.Report)
             .WithMany(r => r.Likes)
             .HasForeignKey(l => l.ReportId)
             .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
