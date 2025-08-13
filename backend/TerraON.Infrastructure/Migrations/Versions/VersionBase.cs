using FluentMigrator;
using FluentMigrator.Builders.Create.Table;

namespace TerraON.Infrastructure.Migrations.Versions
{
    public abstract class VersionBase : ForwardOnlyMigration
    {
        protected ICreateTableColumnOptionOrWithColumnSyntax CreateTable(string tableName)
        {
            return Create.Table(tableName)
                .WithColumn("Id").AsInt64().PrimaryKey().Identity()
                .WithColumn("CreatedAt").AsCustom("timestamp with time zone").NotNullable().WithDefault(SystemMethods.CurrentUTCDateTime)
                .WithColumn("UpdatedAt").AsCustom("timestamp with time zone").Nullable()
                .WithColumn("DeletedAt").AsCustom("timestamp with time zone").Nullable()
                .WithColumn("IsDeleted").AsBoolean().NotNullable().WithDefaultValue(false);
        }
    }
}
