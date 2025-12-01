using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.ReportPosts
{
    public interface IReportPostsUpdateOnlyRepository
    {
        void Update(ReportPost reportPost);
    }
}
