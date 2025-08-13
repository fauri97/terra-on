using Dapper;
using FluentMigrator.Runner;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace TerraON.Infrastructure.Migrations
{
    public class DatabaseMigration
    {
        public static void Migrate(string connectionString, IServiceProvider serviceProvider)
        {
            EnsureDatabaseCreated(connectionString);
            MigrationDatabase(serviceProvider);
        }

        private static void EnsureDatabaseCreated(string connectionString)
        {
            var connectionStringBuilder = new NpgsqlConnectionStringBuilder(connectionString);
            var databaseName = connectionStringBuilder.Database;

            connectionStringBuilder.Remove("Database");

            using var masterConnection = new NpgsqlConnection(connectionStringBuilder.ConnectionString);
            masterConnection.Open();

            var parameters = new DynamicParameters();
            parameters.Add("name", databaseName);

            var exists = masterConnection.QuerySingleOrDefault<bool>(
                @"SELECT EXISTS (SELECT 1 FROM pg_catalog.pg_database WHERE datname = @name);", parameters);

            if (!exists)
            {
                masterConnection.Execute($"CREATE DATABASE \"{databaseName}\"");
            }
            masterConnection.Close();
        }


        private static void MigrationDatabase(IServiceProvider serviceProvider)
        {
            var runner = serviceProvider.GetRequiredService<IMigrationRunner>();
            runner.ListMigrations();
            runner.MigrateUp();
        }
    }
}
