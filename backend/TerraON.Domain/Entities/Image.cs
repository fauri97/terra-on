namespace TerraON.Domain.Entities
{
    public class Image : EntityBase
    {
        public string Base64 { get; set; } = string.Empty;
        public string OriginalFileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public long ReportId { get; set; }
        public Report Report { get; set; } = null!;
    }
}
