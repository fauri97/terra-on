using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.ReportPosts;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ReportPostsRepository(TerraONDbContext context) :
        IReportPostsWriteOnlyRepository,
        IReportPostsReadOnlyRepository,
        IReportPostsUpdateOnlyRepository
    {
        public async Task AddAsync(ReportPost reportPost)
            => await context.ReportPosts.AddAsync(reportPost);

        public async Task<IEnumerable<ReportPost>> GetAllAsync()
            => await context.ReportPosts
                .Include(rp => rp.Report)
                .Include(rp => rp.User)
                    .ThenInclude(u => u.ProfileImage)
                .ToListAsync();

        public async Task<ReportPost?> GetByIdAsync(long id)
            => await context.ReportPosts
                .Include(rp => rp.Report)
                .Include(rp => rp.User)
                    .ThenInclude(u => u.ProfileImage)
                .FirstOrDefaultAsync(rp => rp.Id == id);

        public void Update(ReportPost reportPost)
            => context.ReportPosts.Update(reportPost);
    }
}
