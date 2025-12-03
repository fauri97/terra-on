using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Reports
{
    public interface IReportPdfExporter
    {
        byte[] Generate(IEnumerable<Report> reports, string? title = null);
    }
}
