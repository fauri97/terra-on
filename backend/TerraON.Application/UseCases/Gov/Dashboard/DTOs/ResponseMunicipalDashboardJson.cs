namespace TerraON.Application.UseCases.Gov.Dashboard.DTOs
{
    public sealed class ReportsPerDayMunicipal
    {
        public DateTime Date { get; set; }
        public int ReportCount { get; set; }
    }

    public sealed class ReportsPerNeighborhood
    {
        public string Neighborhood { get; set; } = string.Empty;
        public int ReportCount { get; set; }
    }

    public sealed class ResponseMunicipalDashboardJson
    {
        public string City { get; set; } = string.Empty;

        public int TotalPosts { get; set; }
        public int TotalPostsToday { get; set; }
        public int TotalComments { get; set; }

        public int Pending { get; set; }
        public int InProgress { get; set; }
        public int Resolved { get; set; }
        public int Dismissed { get; set; }
        public int Inappropriate { get; set; }
        public int Diactivated { get; set; }

        public List<ReportsPerDayMunicipal> ReportsPerDay { get; set; } = [];
        public List<ReportsPerNeighborhood> ReportsPerNeighborhood { get; set; } = [];
    }
}
