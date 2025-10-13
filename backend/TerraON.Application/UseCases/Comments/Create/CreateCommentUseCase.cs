using TerraON.Application.UseCases.Comments.Create.DTOs;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Comments;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Comments.Create
{
    public class CreateCommentUseCase (
        ICommentWriteOnlyRepository commentWriteOnlyRepository,
        IReportReadOnlyRepository reportReadOnlyRepository,
        IUserReadOnlyRepository userReadOnlyRepository,
        IUnityOfWork unityOfWork) : ICreateCommentUseCase
    {
        private readonly ICommentWriteOnlyRepository _commentWriteOnlyRepository = commentWriteOnlyRepository;
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;

        public async Task Execute(RequestCreateCommentJson request)
        {
            await Validate(request);
            
            var comment = new Domain.Entities.Comment
            {
                ReportId = request.ReportId,
                AuthorId = request.AuthorId,
                Content = request.Content,
                CreatedAt = DateTime.UtcNow
            };

            await _commentWriteOnlyRepository.AddAsync(comment);
            await _unityOfWork.SaveChangesAsync();
        }

        private async Task Validate(RequestCreateCommentJson request)
        {
            var validator = new CreateCommetValidator();
            var result = validator.Validate(request);

            if (!await _userReadOnlyRepository.ExistActiveUserWithID(request.AuthorId))
            {
                result.Errors.Add(new FluentValidation.Results.ValidationFailure(
                    string.Empty,
                    TerraON.Exception.ResourceMessagesExceptions.USER_ID_INVALID));
            }

            if (!await _reportReadOnlyRepository.ExistsByIdAsync(request.ReportId))
            {
                result.Errors.Add(new FluentValidation.Results.ValidationFailure(
                    string.Empty,
                    TerraON.Exception.ResourceMessagesExceptions.REPORTID_INVALID));
            }

            if (!result.IsValid)
            {
                var errorMessages = result.Errors.Select(e => e.ErrorMessage).ToList();
                throw new BusinessValidationException(errorMessages);
            }
        }
    }
}
