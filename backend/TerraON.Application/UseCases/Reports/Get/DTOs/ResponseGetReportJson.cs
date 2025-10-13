namespace TerraON.Application.UseCases.Reports.Get.DTOs
{
    public class ResponseGetReportJson
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
        public List<string> ImagesBase64 { get; set; } = new();
    }
}
