namespace TerraON.Application.UseCases.Reports.ExportPdf.DTOs
{
    public class ExportPDFFilter
    {
        public string? Status { get; set; }
        public string? City { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
    }
}
