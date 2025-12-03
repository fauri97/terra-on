using TerraON.Application.UseCases.Reports.Get.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Reports.Get
{
    public class GetReportUseCase(
        IReportReadOnlyRepository reportReadOnlyRepository,
        IUserReadOnlyRepository userReadOnlyRepository) : IGetReportUseCase
    {
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;

        public async Task<List<ResponseGetReportJson>> ExecuteAsync()
        {
            var reports = await _reportReadOnlyRepository.GetAllAsync();

            static InlineImageJson? BuildInline(User? user)
            {
                var img = user?.ProfileImage;
                if (img == null || (img.Data?.Length ?? 0) == 0) return null;

                return new InlineImageJson
                {
                    Base64 = Convert.ToBase64String(img.Data!),
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
                    Base64 = Convert.ToBase64String(img.Data!),
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
                    Base64 = Convert.ToBase64String(img.Data),
                    ContentType = string.IsNullOrWhiteSpace(img.ContentType)
                        ? "image/webp" : img.ContentType,
                    SizeBytes = img.SizeBytes > 0 ? img.SizeBytes : null
                };
            }

            var list = reports.Select(r => new ResponseGetReportJson
            {
                Id = r.Id,
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
                AuthorAvatar = BuildInline(r.Author),
                LikeCount = r.Likes?.Count ?? 0,
                Status = r.Status.ToString(),
                Likes = [.. (r.Likes ?? [])
                    .Select(l => new LikesJson
                    {
                        UserId = l.UserId,
                        UserName = l.User?.Name ?? string.Empty
                    })
                ],
                Comments = [.. (r.Comments ?? Enumerable.Empty<Comment>())
                    .Select(c => new CommentsJson
                    {
                        Id = c.Id,
                        Text = c.Content,
                        AuthorId = c.AuthorId,
                        AuthorName = c.Author?.Name ?? string.Empty,
                        AuthorAvatar = BuildInlineFrom(c)
                    })
                ],
                Images = [.. (r.Images ?? Enumerable.Empty<Image>())
                    .Select(MapReportImage)
                ]
            }).ToList();

            return list;
        }

        public async Task<List<ResponseGetReportJson>> GetMyReports(Guid userIdentifier)
        {
            var user = await _userReadOnlyRepository.GetByUserIdentifier(userIdentifier)
                ?? throw new NotFoundException("Usuário não encontrado.");

            var reports = await _reportReadOnlyRepository.GetByUserIdAsync(user.Id);

            static InlineImageJson? BuildInline(User? user)
            {
                var img = user?.ProfileImage;
                if (img == null || (img.Data?.Length ?? 0) == 0) return null;
                return new InlineImageJson
                {
                    Base64 = Convert.ToBase64String(img.Data!),
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
                    Base64 = Convert.ToBase64String(img.Data),
                    ContentType = string.IsNullOrWhiteSpace(img.ContentType)
                        ? "image/webp" : img.ContentType,
                    SizeBytes = img.SizeBytes > 0 ? img.SizeBytes : null
                };
            }

            var list = reports.Select(r => new ResponseGetReportJson
            {
                Id = r.Id,
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
                AuthorAvatar = BuildInline(r.Author),
                Comments = [.. (r.Comments ?? Enumerable.Empty<Comment>())
                    .Select(c => new CommentsJson
                    {
                        Id = c.Id,
                        Text = c.Content,
                        AuthorId = c.AuthorId,
                        AuthorName = c.Author?.Name ?? string.Empty,
                        AuthorAvatar = BuildInline(c.Author)
                    })
                ],
                Images = [.. (r.Images ?? Enumerable.Empty<Image>())
                    .Select(MapReportImage)
                ]
            }).ToList();

            return list;
        }
    }
}
