using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.UPDATE_USER_TABLE, "Update User Table")]
    public class Version00003 : VersionBase
    {
        public override void Up()
        {
            Alter.Table("Users")
                .AddColumn("City").AsString().Nullable()
                .AddColumn("State").AsString().Nullable()
                .AddColumn("ProfileImageId").AsInt64().Nullable().ForeignKey("Images", "Id");

            Alter.Column("ReportId").OnTable("Images").AsInt64().Nullable();
        }
    }
}
