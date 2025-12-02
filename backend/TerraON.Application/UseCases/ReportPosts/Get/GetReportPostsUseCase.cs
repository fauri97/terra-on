using TerraON.Application.UseCases.ReportPosts.Get.DTOs;
using TerraON.Domain.Repositories.ReportPosts;

namespace TerraON.Application.UseCases.ReportPosts.Get
{
    public class GetReportPostsUseCase(IReportPostsReadOnlyRepository reportPostsReadOnlyRepository) : IGetReportPostsUseCase
    {
        private readonly IReportPostsReadOnlyRepository _reportPostsReadOnlyRepository = reportPostsReadOnlyRepository;
        public async Task<List<ResponseGetReportPostsJson>> ExecuteAsync()
        {
            var reportPosts = await _reportPostsReadOnlyRepository.GetAllAsync();

            return [.. reportPosts.Select(rp => new ResponseGetReportPostsJson
            {
                Id = rp.Id,
                ReportId = rp.Report!.Id,
                ReportDescription = rp.Report.Description,
                UserId = rp.User!.Id,
                UserName = rp.User.Name,
                Reason = rp.Reason,
                Status = rp.Status.ToString(),
                ImagesBase64 = [.. rp.Report.Images!.Select(img => Convert.ToBase64String(img.Data))]
            })];
        }
    }
}
