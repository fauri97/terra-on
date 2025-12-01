using TerraON.Application.UseCases.Admin.Dashboard.DTOs;

namespace TerraON.Application.UseCases.Admin.Dashboard
{
    public interface IGetAdminDashboardUseCase
    {
        Task<ResponseAdminDashboardJson> ExecuteAsync();
    }
}
