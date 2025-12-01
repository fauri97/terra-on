namespace TerraON.Domain.Repositories.ReportPosts
{
    public interface IReportPostsWriteOnlyRepository
    {
        Task AddAsync(Entities.ReportPost reportPost);
    }
}
