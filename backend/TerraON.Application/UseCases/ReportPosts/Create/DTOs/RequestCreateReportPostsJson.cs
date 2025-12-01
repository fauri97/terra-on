namespace TerraON.Application.UseCases.ReportPosts.Create.DTOs
{
    public class RequestCreateReportPostsJson
    {
        public long PostId { get; set; }
        public string Reason { get; set; } = string.Empty;
    }
}
