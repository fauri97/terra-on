using TerraON.Application.UseCases.Gov.Dashboard.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Comments;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Application.UseCases.Gov.Dashboard
{
    public class GetMunicipalDashboardUseCase(
        IReportReadOnlyRepository reportReadOnlyRepository
    ) : IGetMunicipalDashboardUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;

        public async Task<ResponseMunicipalDashboardJson> ExecuteAsync(string city)
        {
            if (string.IsNullOrWhiteSpace(city))
                throw new ArgumentException("Cidade deve ser informada.", nameof(city));

            var today = DateTime.UtcNow.Date;
            var requestedCity = city.Trim();

            // ----- Puxa todos os reports e filtra pela cidade -----
            var allReports = await _reportReadOnlyRepository.GetAllAsync();

            var cityReports = allReports
                .Where(r =>
                    !string.IsNullOrWhiteSpace(r.City) &&
                    string.Equals(
                        r.City.Trim(),
                        requestedCity,
                        StringComparison.OrdinalIgnoreCase
                    )
                )
                .ToList();

            // Se quiser, você pode pegar o nome "oficial" da cidade do banco:
            var normalizedCityName = cityReports
                .Select(r => r.City)
                .FirstOrDefault() ?? requestedCity;

            // ----- Totais básicos -----
            var totalPosts = cityReports.Count;

            // Comentários apenas dos reports dessa cidade
            var totalComments = cityReports.Sum(r => r.Comments.Count);

            var totalPostsToday = cityReports
                .Count(r => r.CreatedAt.Date == today);

            // ----- Totais por status -----
            var pending = cityReports.Count(r => r.Status == ReportStatus.Pending);
            var inProgress = cityReports.Count(r => r.Status == ReportStatus.InProgress);
            var resolved = cityReports.Count(r => r.Status == ReportStatus.Resolved);
            var dismissed = cityReports.Count(r => r.Status == ReportStatus.Dismissed);
            var inappropriate = cityReports.Count(r => r.Status == ReportStatus.Inappropriate);
            var diactivated = cityReports.Count(r => r.Status == ReportStatus.Diactivated);

            // ----- Relatórios por dia (últimos 30 dias, incluindo dias sem denúncia) -----
            var fromDate = today.AddDays(-29);

            var reportsPerDayRaw = cityReports
                .Where(r => r.CreatedAt.Date >= fromDate)
                .GroupBy(r => r.CreatedAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Count = g.Count()
                })
                .ToList();

            var reportsPerDay = new List<ReportsPerDayMunicipal>();

            for (int i = 0; i < 30; i++)
            {
                var date = fromDate.AddDays(i);
                var found = reportsPerDayRaw.FirstOrDefault(x => x.Date == date);

                reportsPerDay.Add(new ReportsPerDayMunicipal
                {
                    Date = date,
                    ReportCount = found?.Count ?? 0
                });
            }

            // ----- Relatórios por bairro (dentro da cidade) -----
            var reportsPerNeighborhood = cityReports
                .GroupBy(r => r.Bairro)
                .Select(g => new ReportsPerNeighborhood
                {
                    Neighborhood = g.Key ?? string.Empty,
                    ReportCount = g.Count()
                })
                .OrderByDescending(x => x.ReportCount)
                .ToList();

            // ----- Monta response -----
            var response = new ResponseMunicipalDashboardJson
            {
                City = normalizedCityName,
                TotalPosts = totalPosts,
                TotalPostsToday = totalPostsToday,
                TotalComments = totalComments,

                Pending = pending,
                InProgress = inProgress,
                Resolved = resolved,
                Dismissed = dismissed,
                Inappropriate = inappropriate,
                Diactivated = diactivated,

                ReportsPerDay = reportsPerDay,
                ReportsPerNeighborhood = reportsPerNeighborhood
            };

            return response;
        }
    }
}
