namespace TerraON.Domain.Entities
{
    public class ReportPost : EntityBase
    {
        public long ReportId { get; set; }
        public long UserId { get; set; }
        public string Reason { get; set; } = string.Empty;
        public ReportPostStatus Status { get; set; } = ReportPostStatus.Pendente;
        public Report? Report { get; set; }
        public User? User { get; set; }
    }

    public enum ReportPostStatus
    {
        Pendente,
        Revisado,
        Recusado
    }
}
