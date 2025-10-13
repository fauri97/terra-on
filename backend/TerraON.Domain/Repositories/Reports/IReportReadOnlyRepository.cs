using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Reports
{
    public interface IReportReadOnlyRepository
    {
        public Task<IEnumerable<Report>> GetAllAsync();
        public Task<bool> ExistsByIdAsync(long id);
    }
}
