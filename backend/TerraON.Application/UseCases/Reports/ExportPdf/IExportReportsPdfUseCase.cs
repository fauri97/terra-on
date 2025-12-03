using TerraON.Application.UseCases.Reports.ExportPdf.DTOs;

namespace TerraON.Application.UseCases.Reports.ExportPdf
{
    public interface IExportReportsPdfUseCase
    {
        Task<byte[]> ExecuteAsync(ExportPDFFilter filter);
    }
}
