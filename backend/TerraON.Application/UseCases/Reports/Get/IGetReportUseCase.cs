using TerraON.Application.UseCases.Reports.Get.DTOs;

namespace TerraON.Application.UseCases.Reports.Get
{
    public interface IGetReportUseCase
    {
        public Task<List<ResponseGetReportJson>> ExecuteAsync();
    }
}
