using TerraON.Application.UseCases.Reports.Create.DTOs;

namespace TerraON.Application.UseCases.Reports.Create
{
    public interface ICreateReportUseCase
    {
        public Task ExecuteAsync(RequestCreateReportJson requestCreateReportJson);
    }
}
