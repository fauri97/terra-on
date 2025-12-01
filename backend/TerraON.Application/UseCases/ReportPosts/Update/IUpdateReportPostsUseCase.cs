using TerraON.Application.UseCases.ReportPosts.Update.DTOs;

namespace TerraON.Application.UseCases.ReportPosts.Update
{
    public interface IUpdateReportPostsUseCase
    {
        public Task<bool> Execute(long reportPostId, RequestUpdatePostsJson newStatus);
    }
}
