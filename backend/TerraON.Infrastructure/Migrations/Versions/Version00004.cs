using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.ADD_REPORTPOST_TABLE, "Create ReportPost Table")]
    public class Version00004 : VersionBase
    {
        public override void Up()
        {
            CreateTable("ReportPosts")
                .WithColumn("Reason").AsString(int.MaxValue).NotNullable()
                .WithColumn("Status").AsInt32().NotNullable()
                .WithColumn("UserId").AsInt64().NotNullable().ForeignKey("Users", "Id")
                .WithColumn("ReportId").AsInt64().NotNullable().ForeignKey("Reports", "Id");

            Alter.Table("Reports")
                .AddColumn("Status").AsInt32().NotNullable().WithDefaultValue(0);
        }
    }
}
