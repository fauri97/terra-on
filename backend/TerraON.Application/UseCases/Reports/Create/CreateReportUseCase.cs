using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Application.UseCases.Users.Register;
using TerraON.Application.UseCases.Users.Register.DTOs;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Images;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Reports.Create
{
    public class CreateReportUseCase
        (IImageWriteOnlyRepository imageWriteOnlyRepository,
        IReportWriteOnlyRepository reportWriteOnlyRepository,
        IUnityOfWork unityOfWork) : ICreateReportUseCase
    {
        private readonly IImageWriteOnlyRepository _imageWriteOnlyRepository = imageWriteOnlyRepository;
        private readonly IReportWriteOnlyRepository _reportWriteOnlyRepository = reportWriteOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public Task ExecuteAsync(RequestCreateReportJson requestCreateReportJson)
        {
            throw new NotImplementedException();
        }

        private async Task Validate(RequestCreateReportJson request)
        {
            var validator = new CreateReportValidator();
            var result = validator.Validate(request);

            if (result.IsValid == false)
            {
                var errorMessages = result.Errors.Select(e => e.ErrorMessage);
                throw new BusinessValidationException(errorMessages.ToList());
            }
        }
    }
}
