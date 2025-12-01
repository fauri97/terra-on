using TerraON.Application.UseCases.ReportPosts.Update.DTOs;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.ReportPosts;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.ReportPosts.Update
{
    public class UpdateReportPostsUseCase (
        IReportPostsReadOnlyRepository reportPostsReadOnlyRepository,
        IReportPostsUpdateOnlyRepository reportPostsUpdateOnlyRepository,
        IUnityOfWork unityOfWork) : IUpdateReportPostsUseCase
    {
        private readonly IReportPostsReadOnlyRepository _reportPostsReadOnlyRepository = reportPostsReadOnlyRepository;
        private readonly IReportPostsUpdateOnlyRepository _reportPostsUpdateOnlyRepository = reportPostsUpdateOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;

        public async Task<bool> Execute(long reportPostId, RequestUpdatePostsJson newStatus)
        {
            var reportPost = await _reportPostsReadOnlyRepository.GetByIdAsync(reportPostId)
                ?? throw new NotFoundException("Report não encontrado");

            reportPost.Status = newStatus.NewStatus.ToLower() switch
            {
                "revisado" => Domain.Entities.ReportPostStatus.Revisado,
                "recusado" => Domain.Entities.ReportPostStatus.Recusado,
                "pendente" => Domain.Entities.ReportPostStatus.Pendente,
                _ => throw new BusinessValidationException("Status inválido"),
            };

            _reportPostsUpdateOnlyRepository.Update(reportPost);

            await _unityOfWork.SaveChangesAsync();
            return true;
        }
    }
}
