using TerraON.Application.UseCases.Gov.Dashboard.DTOs;

namespace TerraON.Application.UseCases.Gov.Dashboard
{
    public interface IGetMunicipalDashboardUseCase
    {
        Task<ResponseMunicipalDashboardJson> ExecuteAsync(string city);
    }
}
