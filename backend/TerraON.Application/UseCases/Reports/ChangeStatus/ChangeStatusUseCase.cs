using TerraON.Application.UseCases.Reports.ChangeStatus.DTOs;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Reports;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Reports.ChangeStatus
{
    public class ChangeStatusUseCase(
        IReportReadOnlyRepository reportReadOnlyRepository,
        IReportUpdateOnlyRepository reportUpdateOnlyRepository,
        IUnityOfWork unityOfWork
    ) : IChangeStatusUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IReportUpdateOnlyRepository _reportUpdateOnlyRepository = reportUpdateOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public async Task ExecuteAsync(long reportId, RequestReportNewStatusJson request)
        {
            var report = await _reportReadOnlyRepository.GetByIdAsync(reportId)
                ?? throw new NotFoundException("Report não encontrado.");

            switch (request.NewStatus.ToLower())
            {
                case "pending":
                    report.Status = Domain.Entities.ReportStatus.Pending;
                    report.DeletedAt = null;
                    break;
                case "inprogress":
                    report.Status = Domain.Entities.ReportStatus.InProgress;
                    report.DeletedAt = null;
                    break;
                case "resolved":
                    report.Status = Domain.Entities.ReportStatus.Resolved;
                    report.DeletedAt = null;
                    break;
                case "inappropriate":
                    report.Status = Domain.Entities.ReportStatus.Inappropriate;
                    report.DeletedAt = DateTime.UtcNow;
                    break;
                case "dismissed":
                    report.Status = Domain.Entities.ReportStatus.Dismissed;
                    report.DeletedAt = DateTime.UtcNow;
                    break;
                case "diactivated":
                    report.Status = Domain.Entities.ReportStatus.Diactivated;
                    report.DeletedAt = DateTime.UtcNow;
                    break;
                default:
                    throw new TerraONException("Status inválido.");
            }

            _reportUpdateOnlyRepository.Update(report);
            await _unityOfWork.SaveChangesAsync();
        }
    }
}
