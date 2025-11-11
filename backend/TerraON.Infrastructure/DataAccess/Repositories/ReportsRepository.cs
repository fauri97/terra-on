using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ReportsRepository(TerraONDbContext context) : IReportWriteOnlyRepository, IReportReadOnlyRepository
    {
        private readonly TerraONDbContext _context = context;
        public async Task AddReportAsync(Report report)
            => await _context.Reports.AddAsync(report);

        public async Task<bool> ExistsByIdAsync(long id)
            => await _context.Reports.AnyAsync(r => r.Id == id);

        public async Task<IEnumerable<Report>> GetAllAsync()
            => await _context.Reports
                .AsSplitQuery()
                .Include(r => r.Author)
                .Include(r => r.Images)
                .Include(r => r.Comments)
                    .ThenInclude(c => c.Author)
                        .ThenInclude(a => a.ProfileImage)
                .Include(r => r.Likes)
                .ToListAsync();
    }
}
