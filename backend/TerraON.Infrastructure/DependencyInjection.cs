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
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Images;
using TerraON.Domain.Repositories.Comments;
using TerraON.Domain.Repositories.ReportPosts;

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
            services.AddScoped<IUnityOfWork, UnityOfWork>();

            services.AddScoped<IUserReadOnlyRepository, UsersRepository>();
            services.AddScoped<IUserWriteOnlyRepository, UsersRepository>();
            services.AddScoped<IUserUpdateOnlyRepository, UsersRepository>();

            services.AddScoped<IReportWriteOnlyRepository, ReportsRepository>();
            services.AddScoped<IReportReadOnlyRepository, ReportsRepository>();
            services.AddScoped<ILikeRepository, ReportsRepository>();

            services.AddScoped<IImageWriteOnlyRepository, ImagesRepository>();

            services.AddScoped<ICommentWriteOnlyRepository, CommentsRepository>();
            services.AddScoped<ICommentReadOnlyRepository, CommentsRepository>();

            services.AddScoped<IReportPostsWriteOnlyRepository, ReportPostsRepository>();
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
