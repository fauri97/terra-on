using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.ReportPosts
{
    public interface IReportPostsReadOnlyRepository
    {
        Task<IEnumerable<ReportPost>> GetAllAsync();
        Task<ReportPost?> GetByIdAsync(long id);
    }
}
