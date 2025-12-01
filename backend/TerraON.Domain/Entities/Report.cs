namespace TerraON.Domain.Entities
{
    public class Report : EntityBase
    {
        public string Description { get; set; } = string.Empty;
        public long AuthorId { get; set; }
        public User Author { get; set; } = null!;
        public string Longitude { get; set; } = string.Empty;
        public string Latitude { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string Bairro { get; set; } = string.Empty;
        public string CEP { get; set; } = string.Empty;
        public ReportStatus Status { get; set; } = ReportStatus.Pending;
        public ICollection<Image> Images { get; set; } = [];
        public ICollection<Comment> Comments { get; set; } = [];
        public ICollection<Like> Likes { get; set; } = [];
    }

    public enum ReportStatus
    {
        Pending,
        InProgress,
        Resolved,
        Dismissed,
        Inappropriate,
        Diactivated
    }
}
