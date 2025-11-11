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

            static InlineImageJson? BuildInline(User? user)
            {
                var img = user?.ProfileImage;
                if (img == null || (img.Data?.Length ?? 0) == 0) return null;

                return new InlineImageJson
                {
                    Base64 = Convert.ToBase64String(img.Data),                            // puro
                    ContentType = string.IsNullOrWhiteSpace(img.ContentType)
                        ? "image/webp" : img.ContentType,
                    SizeBytes = img.SizeBytes > 0 ? img.SizeBytes : null
                };
            }

            static InlineImageJson? BuildInlineFrom(Comment c)
            {
                var img = c.Author?.ProfileImage;
                if (img == null || (img.Data?.Length ?? 0) == 0) return null;

                return new InlineImageJson
                {
                    Base64 = Convert.ToBase64String(img.Data),                            // puro
                    ContentType = string.IsNullOrWhiteSpace(img.ContentType)
                        ? "image/webp" : img.ContentType,
                    SizeBytes = img.SizeBytes > 0 ? img.SizeBytes : null
                };
            }

            static ReportImageJson MapReportImage(Image img)
            {
                return new ReportImageJson
                {
                    Id = img.Id,
                    Base64 = Convert.ToBase64String(img.Data),                            // puro
                    ContentType = string.IsNullOrWhiteSpace(img.ContentType)
                        ? "image/webp" : img.ContentType,
                    SizeBytes = img.SizeBytes > 0 ? img.SizeBytes : null
                };
            }

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

                // Avatar do autor (puro + contentType)
                AuthorAvatar = BuildInline(r.Author),

                // Comentários
                Comments = [.. (r.Comments ?? Enumerable.Empty<Comment>())
                    .Select(c => new CommentsJson
                    {
                        Id = c.Id,
                        Text = c.Content,
                        AuthorId = c.AuthorId,
                        AuthorName = c.Author?.Name ?? string.Empty,
                        AuthorAvatar = BuildInlineFrom(c) // puro + contentType
                    })
                ],

                // Imagens do report (puras + contentType)
                Images = [.. (r.Images ?? Enumerable.Empty<Image>())
                    .Select(MapReportImage)
                ]
            }).ToList();

            return list;
        }
    }
}
