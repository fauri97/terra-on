using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ReportsRepository(TerraONDbContext context) : IReportWriteOnlyRepository
    {
        private readonly TerraONDbContext _context = context;
        public async Task AddReportAsync(Report report)
            => await _context.Reports.AddAsync(report);
    }
}
