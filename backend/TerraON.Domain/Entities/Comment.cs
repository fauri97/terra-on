namespace TerraON.Domain.Entities
{
    public class Comment : EntityBase
    {
        public string Content { get; set; } = string.Empty;
        public bool IsHidden { get; set; } = false;
        public long AuthorId { get; set; }
        public User Author { get; set; } = null!;
        public long ReportId { get; set; }
        public Report Report { get; set; } = null!;
    }
}
