using TerraON.Application.UseCases.Reports.ChangeStatus.DTOs;

namespace TerraON.Application.UseCases.Reports.ChangeStatus
{
    public interface IChangeStatusUseCase
    {
        Task ExecuteAsync(long reportId, RequestReportNewStatusJson request);
    }
}
