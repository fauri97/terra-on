using TerraON.Application.UseCases.ReportPosts.Update.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.ReportPosts;
using TerraON.Domain.Repositories.Reports;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.ReportPosts.Update
{
    public class UpdateReportPostsUseCase (
        IReportPostsReadOnlyRepository reportPostsReadOnlyRepository,
        IReportPostsUpdateOnlyRepository reportPostsUpdateOnlyRepository,
        IReportReadOnlyRepository reportReadOnlyRepository,
        IReportUpdateOnlyRepository reportUpdateOnlyRepository,
        IUnityOfWork unityOfWork) : IUpdateReportPostsUseCase
    {
        private readonly IReportPostsReadOnlyRepository _reportPostsReadOnlyRepository = reportPostsReadOnlyRepository;
        private readonly IReportPostsUpdateOnlyRepository _reportPostsUpdateOnlyRepository = reportPostsUpdateOnlyRepository;
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IReportUpdateOnlyRepository _reportUpdateOnlyRepository = reportUpdateOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;

        public async Task<bool> Execute(long reportPostId, RequestUpdatePostsJson request)
        {
            var reportPost = await _reportPostsReadOnlyRepository.GetByIdAsync(reportPostId)
                ?? throw new NotFoundException("Report não encontrado");

            var report = await _reportReadOnlyRepository.GetByIdAsync(reportPost.ReportId)
                ?? throw new NotFoundException("Report não encontrado");

            switch(request.NewStatus.ToLower())
            {
                case "pendente":
                    reportPost.Status = ReportPostStatus.Pendente;
                    report.DeletedAt = null;
                    break;
                case "revisado":
                    reportPost.Status = ReportPostStatus.Revisado;
                    report.DeletedAt = DateTime.UtcNow;
                    break;
                case "recusado":
                    reportPost.Status = ReportPostStatus.Recusado;
                    report.DeletedAt = null;
                    break;
                default:
                    throw new BusinessValidationException("Status inválido");
            }

            _reportUpdateOnlyRepository.Update(report);

            _reportPostsUpdateOnlyRepository.Update(reportPost);

            await _unityOfWork.SaveChangesAsync();
            return true;
        }
    }
}
