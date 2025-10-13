namespace TerraON.Application.UseCases.Comments.Create.DTOs
{
    public class RequestCreateCommentJson
    {
        public long ReportId { get; set; }
        public long AuthorId { get; set; }
        public string Content { get; set; } = string.Empty;
    }
}
