using FluentMigrator;

namespace TerraON.Infrastructure.Migrations.Versions
{
    [Migration(DatabaseVersions.ADD_USERROLES, "Add collumn Role in User Table")]
    public class Version00005 : VersionBase
    {
        public override void Up()
        {
            Alter.Table("Users")
                .AddColumn("Role")
                .AsInt32()
                .NotNullable()
                .WithDefaultValue(1); // Default to 'User' role
        }
    }
}
