using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TerraON.Application.Services.AutoMapper;
using TerraON.Application.Services.Cryptography;
using TerraON.Application.UseCases.Users.Login;
using TerraON.Application.UseCases.Users.Register;

namespace TerraON.Application
{
    public static class DependencyInjection
    {

        public static void AddApplication(this IServiceCollection services, IConfiguration configuration)
        {
            AddAutoMapper(services);
            AddUseCases(services);
            addServices(services);
        }

        private static void AddAutoMapper(IServiceCollection services)
        {
            services.AddAutoMapper(cfg => cfg.AddProfile<AutoMapping>(), typeof(AutoMapping).Assembly);
        }

        private static void addServices(IServiceCollection services)
        {
            services.AddScoped<IPasswordService, PasswordService>();
        }

        private static void AddUseCases(IServiceCollection services)
        {
            services.AddScoped<ICreateUserUseCase, CreateUserUseCase>();
            services.AddScoped<IDoLoginUseCase, DoLoginUseCase>();
        }
    }
}
