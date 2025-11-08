using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TerraON.Application.Services.AutoMapper;
using TerraON.Application.Services.Cryptography;
using TerraON.Application.UseCases.Comments.Create;
using TerraON.Application.UseCases.Reports.Create;
using TerraON.Application.UseCases.Reports.Get;
using TerraON.Application.UseCases.Users.Get.Me;
using TerraON.Application.UseCases.Users.Login;
using TerraON.Application.UseCases.Users.Register;
using TerraON.Application.UseCases.Users.Update;

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
            services.AddScoped<IGetMyselfUserUseCase, GetMyselfUserUseCase>();
            services.AddScoped<IUpdateUserUseCase, UpdateUserUseCase>();

            services.AddScoped<ICreateReportUseCase, CreateReportUseCase>();
            services.AddScoped<IGetReportUseCase, GetReportUseCase>();

            services.AddScoped<ICreateCommentUseCase, CreateCommentUseCase>();
        }
    }
}
