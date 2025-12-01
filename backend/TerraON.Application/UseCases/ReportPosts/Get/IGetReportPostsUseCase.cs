using TerraON.Application.UseCases.ReportPosts.Get.DTOs;

namespace TerraON.Application.UseCases.ReportPosts.Get
{
    public interface IGetReportPostsUseCase
    {
        public Task<List<ResponseGetReportPostsJson>> ExecuteAsync();
    }
}
