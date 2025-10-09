namespace TerraON.Domain.Entities
{
    public class Comment : EntityBase
    {
        public string Content { get; set; } = string.Empty;
        public bool IsHidden { get; set; } = false;
        public long UserId { get; set; }
        public User User { get; set; } = null!;
        public long ReportId { get; set; }
        public Report Report { get; set; } = null!;
    }
}
