using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.TABLES_FOR_REPORT, "Create all tables necessary to Create a report")]
    public class Version00002 : VersionBase
    {
        public override void Up()
        {
            CreateTable("Reports")
                .WithColumn("Description").AsString(int.MaxValue).NotNullable()
                .WithColumn("AuthorId").AsInt64().NotNullable().ForeignKey("Users", "Id")
                .WithColumn("Longitude").AsString().NotNullable()
                .WithColumn("Latitude").AsString().NotNullable()
                .WithColumn("Address").AsString().Nullable()
                .WithColumn("City").AsString().Nullable()
                .WithColumn("State").AsString().Nullable()
                .WithColumn("Bairro").AsString().Nullable()
                .WithColumn("CEP").AsString().Nullable();

            CreateTable("Images")
                .WithColumn("Data").AsCustom("bytea").NotNullable()
                .WithColumn("OriginalFileName").AsString(255).NotNullable()
                .WithColumn("ContentType").AsString(100).NotNullable()
                .WithColumn("SizeBytes").AsInt64().NotNullable()
                .WithColumn("Sha256").AsString(64).Nullable()
                .WithColumn("ReportId").AsInt64().NotNullable().ForeignKey("Reports", "Id");

            CreateTable("Comments")
                .WithColumn("Content").AsString(int.MaxValue).NotNullable()
                .WithColumn("IsHidden").AsBoolean().NotNullable().WithDefaultValue(false)
                .WithColumn("AuthorId").AsInt64().NotNullable().ForeignKey("Users", "Id")
                .WithColumn("ReportId").AsInt64().NotNullable().ForeignKey("Reports", "Id");

            CreateTable("Likes")
                .WithColumn("UserId").AsInt64().NotNullable().ForeignKey("Users", "Id")
                .WithColumn("ReportId").AsInt64().NotNullable().ForeignKey("Reports", "Id");

        }
    }
}
