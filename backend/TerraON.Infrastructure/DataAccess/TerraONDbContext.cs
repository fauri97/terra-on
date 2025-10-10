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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            ConfigureUser(modelBuilder);
            ConfigureReport(modelBuilder);
            ConfigureImage(modelBuilder);
            ConfigureComment(modelBuilder);
            ConfigureLike(modelBuilder);

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

        private static void ConfigureUser(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().ToTable("Users");
        }

        private static void ConfigureReport(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Report>();
            e.ToTable("Reports");

            e.HasKey(r => r.Id);

            e.Property(r => r.Title)
                .IsRequired()
                .HasMaxLength(255);

            // Description como TEXT
            e.Property(r => r.Description)
                .IsRequired()
                .HasColumnType("text");

            e.Property(r => r.AuthorId)
                .IsRequired();

            // Relacionamentos
            e.HasOne<User>() // se não tiver navegação Author em Report
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

            e.HasKey(i => i.Id);

            e.Property(i => i.Data)
             .IsRequired()
             .HasColumnType("bytea"); // Postgres binário

            e.Property(i => i.OriginalFileName)
             .IsRequired()
             .HasMaxLength(255);

            e.Property(i => i.ContentType)
             .IsRequired()
             .HasMaxLength(100);

            e.Property(i => i.SizeBytes)
             .IsRequired();

            e.Property(i => i.Sha256)
             .HasMaxLength(64);

            e.Property(i => i.ReportId)
             .IsRequired();

            // FK
            e.HasOne(i => i.Report)
             .WithMany(r => r.Images)
             .HasForeignKey(i => i.ReportId)
             .OnDelete(DeleteBehavior.Cascade);
        }

        private static void ConfigureComment(ModelBuilder modelBuilder)
        {
            var e = modelBuilder.Entity<Comment>();
            e.ToTable("Comments");

            e.HasKey(c => c.Id);

            // Content como TEXT
            e.Property(c => c.Content)
             .IsRequired()
             .HasColumnType("text");

            e.Property(c => c.IsHidden)
             .IsRequired()
             .HasDefaultValue(false);

            e.Property(c => c.AuthorId)
             .IsRequired();

            e.Property(c => c.ReportId)
             .IsRequired();

            // Relacionamentos
            e.HasOne<User>() // caso não exista navegação Author em Comment
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

            // Chave composta para evitar duplicidade (um like por user/report)
            e.HasKey(l => new { l.UserId, l.ReportId });

            e.Property(l => l.UserId).IsRequired();
            e.Property(l => l.ReportId).IsRequired();


            // Relacionamentos
            e.HasOne<User>()
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
