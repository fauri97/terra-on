using TerraON.Application.UseCases.ReportPosts.Create.DTOs;

namespace TerraON.Application.UseCases.ReportPosts.Create
{
    public interface ICreateReportPostsUseCase
    {
        Task CreateAsync (Guid userIndetification, RequestCreateReportPostsJson request);
    }
}
