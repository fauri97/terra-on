using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.ReportPosts;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ReportPostsRepository(TerraONDbContext context) :
        IReportPostsWriteOnlyRepository,
        IReportPostsReadOnlyRepository
    {
        public async Task AddAsync(ReportPost reportPost)
            => await context.ReportPosts.AddAsync(reportPost);

        public async Task<IEnumerable<ReportPost>> GetAllAsync()
            => await context.ReportPosts.ToListAsync();
    }
}
