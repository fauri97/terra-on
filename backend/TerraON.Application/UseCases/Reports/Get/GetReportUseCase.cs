using TerraON.Application.UseCases.Reports.Get.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Application.UseCases.Reports.Get
{
    public class GetReportUseCase : IGetReportUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository;

        public GetReportUseCase(IReportReadOnlyRepository reportReadOnlyRepository)
        {
            _reportReadOnlyRepository = reportReadOnlyRepository;
        }

        public async Task<List<ResponseGetReportJson>> ExecuteAsync()
        {
            var reports = await _reportReadOnlyRepository.GetAllAsync();

            var list = reports.Select(r => new ResponseGetReportJson
            {
                Description = r.Description,
                AuthorId = r.AuthorId,
                AuthorName = r.Author?.Name ?? string.Empty,
                Longitude = r.Longitude,
                Latitude = r.Latitude,
                Address = r.Address ?? string.Empty,
                City = r.City ?? string.Empty,
                State = r.State ?? string.Empty,
                Bairro = r.Bairro ?? string.Empty,
                CEP = r.CEP ?? string.Empty,
                ImagesBase64 = (r.Images ?? Enumerable.Empty<Image>())
                    .Select(img =>
                    {
                        var b64 = Convert.ToBase64String(img.Data);
                        var ct = string.IsNullOrWhiteSpace(img.ContentType) ? "application/octet-stream" : img.ContentType;
                        return $"data:{ct};base64,{b64}";
                    })
                    .ToList()
            }).ToList();

            return list;
        }
    }
}
