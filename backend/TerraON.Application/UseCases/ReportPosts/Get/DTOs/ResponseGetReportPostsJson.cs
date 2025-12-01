using TerraON.Domain.Entities;

namespace TerraON.Application.UseCases.ReportPosts.Get.DTOs
{
    public class ResponseGetReportPostsJson
    {
        public long Id { get; set; }
        public long ReportId { get; set; }
        public string ReportDescription { get; set; } = string.Empty;
        public long UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }
}
