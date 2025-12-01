using TerraON.Application.UseCases.Admin.Dashboard.DTOs;
using TerraON.Domain.Repositories.Comments;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;

namespace TerraON.Application.UseCases.Admin.Dashboard
{
    public class GetAdminDashboardUseCase(
        IReportReadOnlyRepository reportReadOnlyRepository,
        IUserReadOnlyRepository userReadOnlyRepository,
        ICommentReadOnlyRepository commentReadOnlyRepository
    ) : IGetAdminDashboardUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly ICommentReadOnlyRepository _commentReadOnlyRepository = commentReadOnlyRepository;

        public async Task<ResponseAdminDashboardJson> ExecuteAsync()
        {
            var today = DateTime.UtcNow.Date;

            // ----- Usuários -----
            var totalUsers = await _userReadOnlyRepository.GetAllUsersAsync();
            var activeUsers = totalUsers.Count(user => !user.IsDeleted);
            var inactiveUsers = totalUsers.Count(user => user.IsDeleted);

            // ----- Posts (denúncias) -----
            var posts = await _reportReadOnlyRepository.GetAllAsync();
            var totalPosts = posts.Count();

            // ----- Comentários -----
            var totalComments = await _commentReadOnlyRepository.GetTotalCommentsAsync();

            // ----- Cidades com denúncia -----
            var totalReportCities = posts
                .Select(report => report.City)
                .Where(city => city != null)
                .Distinct()
                .Count();

            // ----- Posts hoje -----
            var totalPostsToday = posts
                .Count(report => report.CreatedAt.Date == today);

            // ----- Cidade mais ativa (mais denúncias) -----
            var mostActiveCity = posts
                .GroupBy(r => r.City)
                .Select(g => new
                {
                    City = g.Key,
                    Count = g.Count()
                })
                .OrderByDescending(x => x.Count)
                .FirstOrDefault()?.City ?? string.Empty;

            // ----- Última cidade reportada (denúncia mais recente) -----
            var lastCityReported = posts
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => r.City)
                .FirstOrDefault() ?? string.Empty;

            // ----- Relatórios por dia (ex.: últimos 29 dias) -----
            var fromDate = today.AddDays(-29);

            var reportsPerDayRaw = posts
                .Where(r => r.CreatedAt.Date >= fromDate)
                .GroupBy(r => r.CreatedAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Count = g.Count()
                })
                .ToList();

            var reportsPerDay = new List<ReportsPerDay>();

            for (int i = 0; i < 30; i++)
            {
                var date = fromDate.AddDays(i);
                var found = reportsPerDayRaw.FirstOrDefault(x => x.Date == date);

                reportsPerDay.Add(new ReportsPerDay
                {
                    Date = date,
                    ReportCount = found?.Count ?? 0
                });
            }

            // ----- Relatórios por cidade (geral) -----
            var reportsPerCity = posts
                .GroupBy(r => r.City)
                .Select(g => new ReportPerCity
                {
                    City = g.Key ?? string.Empty,
                    ReportCount = g.Count()
                })
                .OrderByDescending(x => x.ReportCount)
                .ToList();

            var response = new ResponseAdminDashboardJson
            {
                TotalUsers = totalUsers.Count(),
                ActiveUsers = activeUsers,
                InactiveUsers = inactiveUsers,
                TotalPosts = totalPosts,
                TotalComments = totalComments,
                TotalReportCities = totalReportCities,
                MostActiveCity = mostActiveCity,
                LastCityReported = lastCityReported,
                TotalPostsToday = totalPostsToday,
                ReportsPerDay = reportsPerDay,
                ReportsPerCity = reportsPerCity
            };

            return response;
        }
    }
}
