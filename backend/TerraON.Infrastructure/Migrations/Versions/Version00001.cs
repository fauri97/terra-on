using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.TABLE_USERS, "Create table to save Users")]
    public class Version00001 : VersionBase
    {
        public override void Up()
        {
            CreateTable("Users")
                .WithColumn("UserIdentifier").AsGuid().NotNullable()
                .WithColumn("Name").AsString().NotNullable()
                .WithColumn("Email").AsString().NotNullable()
                .WithColumn("NormalizedEmail").AsString().NotNullable()
                .WithColumn("PasswordHash").AsString().NotNullable()
                .WithColumn("PhoneNumber").AsString().Nullable()
                .WithColumn("PhoneId").AsString().Nullable();
        }
    }
}
