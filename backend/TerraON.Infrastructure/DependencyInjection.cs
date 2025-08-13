using Microsoft.Extensions.Configuration;
using System.Reflection;
using FluentMigrator.Runner;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using TerraON.Domain.Security.Tokens;
using TerraON.Domain.Services.LoggedUser;
using TerraON.Infrastructure.DataAccess;
using TerraON.Infrastructure.Extensions;
using TerraON.Infrastructure.Security.Tokens.Access;
using TerraON.Infrastructure.Services.LoggedUser;
using TerraON.Domain.Repositories.Users;
using TerraON.Infrastructure.DataAccess.Repositories;

namespace TerraON.Infrastructure
{
    public static class DependencyInjection
    {
        public static void AddInfra(this IServiceCollection services, IConfiguration configuration)
        {
            AddDbContext(services, configuration);
            AddRepositories(services);
            AddFluentMigrator(services, configuration);
            AddTokens(services, configuration);
            AddLoggedUser(services);
        }

        private static void AddRepositories(IServiceCollection services)
        {
            services.AddScoped<IUserReadOnlyRepository, UsersRepository>();
        }

        private static void AddDbContext(IServiceCollection services, IConfiguration configuration)
        {
            var connectionString = configuration.ConnectionString();
            var isDevelopment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development";

            services.AddDbContext<TerraONDbContext>(options =>
            {
                options.UseNpgsql(connectionString);

                if (isDevelopment)
                {
                    options.EnableSensitiveDataLogging();
                    options.EnableDetailedErrors();
                }
            });
        }

        private static void AddFluentMigrator(IServiceCollection services, IConfiguration configuration)
        {
            var connectionString = configuration.ConnectionString();

            services.AddFluentMigratorCore()
                .ConfigureRunner(rb => rb
                    .AddPostgres()
                    .WithGlobalConnectionString(connectionString)
                    .ScanIn(Assembly.Load("TerraON.Infrastructure")).For.All());
        }

        private static void AddTokens(IServiceCollection services, IConfiguration configuration)
        {
            var expirationTimeInMinutes = configuration.GetValue<uint>("Settings:Jwt:ExpirationTimeMinutes");
            var signingKey = configuration.GetValue<string>("Settings:Jwt:SigningKey");

            services.AddScoped<IAccessTokenGenerator>(x => new JwtTokenGenerator(expirationTimeInMinutes, signingKey!));
            services.AddScoped<IAccessTokenValidator>(x => new JwtTokenValidator(signingKey!));
        }

        private static void AddLoggedUser(IServiceCollection services) => services.AddScoped<ILoggedUser, LoggedUser>();
    }
}
