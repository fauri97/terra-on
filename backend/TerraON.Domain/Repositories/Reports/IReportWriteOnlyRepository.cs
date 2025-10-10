using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Reports
{
    public interface IReportWriteOnlyRepository
    {
        public Task AddReportAsync(Report report);
    }
}
