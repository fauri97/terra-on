namespace TerraON.Application.UseCases.Admin.Dashboard.DTOs
{
    public class ResponseAdminDashboardJson
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int InactiveUsers { get; set; }
        public int TotalPosts { get; set; }
        public int TotalPostsToday { get; set; }
        public int TotalComments { get; set; }
        public int TotalReportCities { get; set; }
        public string MostActiveCity { get; set; } = string.Empty;
        public string LastCityReported { get; set; } = string.Empty;
        public List<ReportsPerDay> ReportsPerDay { get; set; } = new();
        public List<ReportPerCity> ReportsPerCity { get; set; } = new();
    }

    public class ReportsPerDay
    {
        public DateTime Date { get; set; }
        public int ReportCount { get; set; }
    }

    public class ReportPerCity
    {
        public string City { get; set; } = string.Empty;
        public int ReportCount { get; set; }
    }
}
