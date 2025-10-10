using FluentValidation;
using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Exception;

namespace TerraON.Application.UseCases.Reports.Create
{
    public class CreateReportValidator : AbstractValidator<RequestCreateReportJson>
    {
        public CreateReportValidator() { 
            RuleFor(x => x.Description)
                .NotEmpty().WithMessage(ResourceMessagesExceptions.REPORT_CONTENT_NOT_EMPTY)
                .MaximumLength(3000).WithMessage(ResourceMessagesExceptions.REPORT_MAX_LENGTH);

            RuleFor(x => x.AuthorId)
                .GreaterThan(0).WithMessage(ResourceMessagesExceptions.USER_ID_INVALID);
        }
    }
}
