using AutoMapper;
using TerraON.Application.Services.Image;
using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Reports.Create
{
    public class CreateReportUseCase
        : ICreateReportUseCase
    {
        private readonly IReportWriteOnlyRepository _reportWriteOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository;
        private readonly IMapper _mapper;
        private readonly IUnityOfWork _unityOfWork;

        // limites de segurança (ajuste se quiser)
        private const long MaxImageBytes = 20 * 1024 * 1024;

        public CreateReportUseCase(
            IReportWriteOnlyRepository reportWriteOnlyRepository,
            IUserReadOnlyRepository userReadOnlyRepository,
            IMapper mapper,
            IUnityOfWork unityOfWork)
        {
            _reportWriteOnlyRepository = reportWriteOnlyRepository;
            _userReadOnlyRepository = userReadOnlyRepository;
            _mapper = mapper;
            _unityOfWork = unityOfWork;
        }

        public async Task ExecuteAsync(RequestCreateReportJson request)
        {
            await Validate(request);

            // Mapeia campos básicos do Report
            var report = _mapper.Map<Report>(request);
            report.CreatedAt = DateTime.UtcNow;

            // Converte e anexa imagens (serão salvas em cascata)
            if (request.ImagesBase64 is not null)
            {
                var seenHashes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                foreach (var imgB64 in request.ImagesBase64.Where(s => !string.IsNullOrWhiteSpace(s)))
                {
                    if (!Base64ToByteaService.TryDecode(imgB64, out var data, out var contentType, out var sizeBytes))
                        continue;

                    if (sizeBytes <= 0 || sizeBytes > MaxImageBytes)
                        continue;

                    var sha = Base64ToByteaService.ComputeSha256Hex(data);

                    if (!seenHashes.Add(sha))
                        continue;

                    var ext = (contentType.Split('/').LastOrDefault() ?? "bin").ToLowerInvariant();
                    var fileName = $"{sha[..8]}.{ext}";

                    report.Images.Add(new Image
                    {
                        Data = data,
                        ContentType = contentType,
                        SizeBytes = sizeBytes,
                        Sha256 = sha,
                        OriginalFileName = fileName
                    });
                }
            }

            await _reportWriteOnlyRepository.AddReportAsync(report);
            await _unityOfWork.SaveChangesAsync();
        }

        private async Task Validate(RequestCreateReportJson request)
        {
            var validator = new CreateReportValidator();
            var result = validator.Validate(request);

            if (!await _userReadOnlyRepository.ExistActiveUserWithID(request.AuthorId))
            {
                result.Errors.Add(new FluentValidation.Results.ValidationFailure(
                    string.Empty,
                    TerraON.Exception.ResourceMessagesExceptions.USER_ID_INVALID));
            }

            if (!result.IsValid)
            {
                var errorMessages = result.Errors.Select(e => e.ErrorMessage).ToList();
                throw new BusinessValidationException(errorMessages);
            }
        }
    }
}
