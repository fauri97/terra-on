namespace TerraON.Domain.Entities
{
    public class Like
    {
        public long UserId { get; set; }
        public User User { get; set; } = null!;
        public long ReportId { get; set; }
        public Report Report { get; set; } = null!;
    }
}
