using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.TABLES_FOR_REPORT, "Create all tables necessary to Create a report")]
    public class Version00002 : VersionBase
    {
        public override void Up()
        {
            CreateTable("Reports")
                .WithColumn("Title").AsString().NotNullable()
                .WithColumn("Description").AsString(int.MaxValue).NotNullable()
                .WithColumn("AuthorId").AsInt64().NotNullable().ForeignKey("Users", "Id")
                .WithColumn("Longitude").AsString().NotNullable()
                .WithColumn("Latitude").AsString().NotNullable()
                .WithColumn("Address").AsString().NotNullable()
                .WithColumn("City").AsString().NotNullable()
                .WithColumn("State").AsString().NotNullable()
                .WithColumn("Bairro").AsString().NotNullable()
                .WithColumn("CEP").AsString().NotNullable();

            CreateTable("Images")
                .WithColumn("Base64").AsString(int.MaxValue).NotNullable()
                .WithColumn("OriginalFileName").AsString().NotNullable()
                .WithColumn("ContentType").AsString().NotNullable()
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
