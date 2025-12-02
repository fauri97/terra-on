using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ReportsRepository(TerraONDbContext context) : 
        IReportWriteOnlyRepository,
        IReportReadOnlyRepository,
        IReportUpdateOnlyRepository,
        ILikeRepository
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
                    .ThenInclude(p => p.ProfileImage)
                .Include(r => r.Images)
                .Include(r => r.Comments)
                    .ThenInclude(c => c.Author)
                        .ThenInclude(a => a.ProfileImage)
                .Include(r => r.Likes)
                .OrderByDescending(r => r.CreatedAt)
                .Where(r => r.DeletedAt == null)
                .ToListAsync();

        public async Task<IEnumerable<Report>> GetByUserIdAsync(long userId)
            => await _context.Reports
                .AsSplitQuery()
                .Where(r => r.AuthorId == userId)
                .Include(r => r.Author)
                    .ThenInclude(p => p.ProfileImage)
                .Include(r => r.Images)
                .Include(r => r.Comments)
                    .ThenInclude(c => c.Author)
                        .ThenInclude(a => a.ProfileImage)
                .Include(r => r.Likes)
                .OrderByDescending(r => r.CreatedAt)
                .Where(r => r.DeletedAt == null)
                .ToListAsync();

        public async Task Like(Like entity)
            => await _context.AddAsync(entity);
        public void Dislike(Like entity)
            => _context.Remove(entity);
        public async Task<Like?> GetLike(long reportId, long userId)
            => await _context.Likes
                .FirstOrDefaultAsync(l => l.ReportId == reportId && l.UserId == userId);
        public async Task<Report?> GetByIdAsync(long id)
            => await _context.Reports
                .AsSplitQuery()
                .Include(r => r.Author)
                    .ThenInclude(p => p.ProfileImage)
                .Include(r => r.Images)
                .Include(r => r.Comments)
                    .ThenInclude(c => c.Author)
                        .ThenInclude(a => a.ProfileImage)
                .Include(r => r.Likes)
                .FirstOrDefaultAsync(r => r.Id == id);

        public void Update(Report report)
            => _context.Reports.Update(report);
    }
}
