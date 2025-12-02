using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Reports
{
    public interface IReportUpdateOnlyRepository
    {
        void Update(Report report);
    }
}
