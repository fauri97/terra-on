using TerraON.Domain.Entities;

namespace TerraON.Application.UseCases.ReportPosts.Get.DTOs
{
    public class ResposeGetReportPostsJson
    {
        public Report? ReportId { get; set; }
        public User? User { get; set; }
        public string Reason { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }
}
