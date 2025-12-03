using TerraON.Application.UseCases.Reports.ExportPdf.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Application.UseCases.Reports.ExportPdf
{
    public class ExportReportsPdfUseCase : IExportReportsPdfUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository;
        private readonly IReportPdfExporter _reportPdfExporter;

        public ExportReportsPdfUseCase(
            IReportReadOnlyRepository reportReadOnlyRepository,
            IReportPdfExporter reportPdfExporter)
        {
            _reportReadOnlyRepository = reportReadOnlyRepository;
            _reportPdfExporter = reportPdfExporter;
        }

        public async Task<byte[]> ExecuteAsync(ExportPDFFilter filter)
        {
            // 1) Busca todas as denúncias (se tiver método mais específico, pode trocar)
            var reports = await _reportReadOnlyRepository.GetAllAsync();
            var query = reports.AsQueryable();

            // 2) Filtro por status (texto → enum ReportStatus)
            if (!string.IsNullOrWhiteSpace(filter.Status) &&
                Enum.TryParse<ReportStatus>(filter.Status, ignoreCase: true, out var parsedStatus))
            {
                query = query.Where(r => r.Status == parsedStatus);
            }

            // 3) Filtro por cidade
            if (!string.IsNullOrWhiteSpace(filter.City))
            {
                query = query.Where(r =>
                    r.City != null &&
                    r.City.Equals(filter.City, StringComparison.OrdinalIgnoreCase));
            }

            // 4) Filtros de período (assumindo CreatedAt em EntityBase)
            if (filter.From.HasValue)
            {
                query = query.Where(r => r.CreatedAt >= filter.From.Value);
            }

            if (filter.To.HasValue)
            {
                // até o final do dia, se quiser mais amigável:
                var toDate = filter.To.Value;
                if (toDate.TimeOfDay == TimeSpan.Zero)
                    toDate = toDate.Date.AddDays(1).AddTicks(-1);

                query = query.Where(r => r.CreatedAt <= toDate);
            }

            var list = query
                .OrderByDescending(r => r.CreatedAt)
                .ToList();

            var title = "Relatório de Denúncias - TerraON";

            if (!string.IsNullOrWhiteSpace(filter.City))
                title += $" · Cidade: {filter.City}";

            if (filter.From.HasValue && filter.To.HasValue)
                title += $" · Período: {filter.From:dd/MM/yyyy} a {filter.To:dd/MM/yyyy}";
            else if (filter.From.HasValue)
                title += $" · A partir de {filter.From:dd/MM/yyyy}";
            else if (filter.To.HasValue)
                title += $" · Até {filter.To:dd/MM/yyyy}";

            var pdfBytes = _reportPdfExporter.Generate(list, title);

            return pdfBytes;
        }
    }
}
