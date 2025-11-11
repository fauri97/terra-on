namespace TerraON.Application.UseCases.Reports.Get.DTOs
{
    public sealed class InlineImageJson
    {
        public string Base64 { get; set; } = string.Empty;   // base64 puro
        public string ContentType { get; set; } = "image/webp";
        public long? SizeBytes { get; set; }                // opcional, útil p/ diagnosticar
    }

    public sealed class ReportImageJson
    {
        public long Id { get; set; }
        public string Base64 { get; set; } = string.Empty;   // base64 puro
        public string ContentType { get; set; } = "image/webp";
        public long? SizeBytes { get; set; }
    }

    public sealed class CommentsJson
    {
        public long Id { get; set; }
        public string Text { get; set; } = string.Empty;
        public long AuthorId { get; set; }
        public string AuthorName { get; set; } = string.Empty;
        public InlineImageJson? AuthorAvatar { get; set; }   // avatar puro + contentType
    }

    public sealed class ResponseGetReportJson
    {
        public string Description { get; set; } = string.Empty;
        public long AuthorId { get; set; }
        public string AuthorName { get; set; } = string.Empty;

        public string Longitude { get; set; } = string.Empty;
        public string Latitude { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string Bairro { get; set; } = string.Empty;
        public string CEP { get; set; } = string.Empty;

        public InlineImageJson? AuthorAvatar { get; set; }   // avatar puro + contentType

        public List<CommentsJson> Comments { get; set; } = [];
        public List<ReportImageJson> Images { get; set; } = []; // imagens do report
    }
}
