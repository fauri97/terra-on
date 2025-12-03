using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TerraON.Application.Services.AutoMapper;
using TerraON.Application.Services.Cryptography;
using TerraON.Application.UseCases.Admin.Dashboard;
using TerraON.Application.UseCases.Comments.Create;
using TerraON.Application.UseCases.ReportPosts.Create;
using TerraON.Application.UseCases.ReportPosts.Get;
using TerraON.Application.UseCases.ReportPosts.Update;
using TerraON.Application.UseCases.Reports.ChangeStatus;
using TerraON.Application.UseCases.Reports.Create;
using TerraON.Application.UseCases.Reports.ExportPdf;
using TerraON.Application.UseCases.Reports.Get;
using TerraON.Application.UseCases.Reports.Like;
using TerraON.Application.UseCases.Users.Get.All;
using TerraON.Application.UseCases.Users.Get.Me;
using TerraON.Application.UseCases.Users.HandleActivation;
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
            AddServices(services);
        }

        private static void AddAutoMapper(IServiceCollection services)
        {
            services.AddAutoMapper(cfg => cfg.AddProfile<AutoMapping>(), typeof(AutoMapping).Assembly);
        }

        private static void AddServices(IServiceCollection services)
        {
            services.AddScoped<IPasswordService, PasswordService>();
        }

        private static void AddUseCases(IServiceCollection services)
        {
            services.AddScoped<ICreateUserUseCase, CreateUserUseCase>();
            services.AddScoped<IDoLoginUseCase, DoLoginUseCase>();
            services.AddScoped<IGetMyselfUserUseCase, GetMyselfUserUseCase>();
            services.AddScoped<IGetUsersUseCase, GetUsersUseCase>();
            services.AddScoped<IUpdateUserUseCase, UpdateUserUseCase>();
            services.AddScoped<IHandleUserActivityUseCase, HandleUserActivityUseCase>();

            services.AddScoped<ICreateReportUseCase, CreateReportUseCase>();
            services.AddScoped<IGetReportUseCase, GetReportUseCase>();
            services.AddScoped<IChangeStatusUseCase, ChangeStatusUseCase>();
            services.AddScoped<IExportReportsPdfUseCase, ExportReportsPdfUseCase>();
            services.AddScoped<IToggleLikeUseCase, ToggleLikeUseCase>();

            services.AddScoped<ICreateCommentUseCase, CreateCommentUseCase>();

            services.AddScoped<ICreateReportPostsUseCase, CreateReportPostsUseCase>();
            services.AddScoped<IGetReportPostsUseCase, GetReportPostsUseCase>();
            services.AddScoped<IUpdateReportPostsUseCase, UpdateReportPostsUseCase>();

            services.AddScoped<IGetAdminDashboardUseCase, GetAdminDashboardUseCase>();
        }
    }
}
