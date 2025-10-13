namespace TerraON.Domain.Entities
{
    public class Image : EntityBase
    {
        public byte[] Data { get; set; } = Array.Empty<byte>();
        public string OriginalFileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public long SizeBytes { get; set; }
        public string? Sha256 { get; set; }
        public long ReportId { get; set; }
        public Report Report { get; set; } = null!;
    }
}
