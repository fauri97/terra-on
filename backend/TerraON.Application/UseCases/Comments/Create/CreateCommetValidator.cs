using FluentValidation;
using TerraON.Application.UseCases.Comments.Create.DTOs;
using TerraON.Exception;

namespace TerraON.Application.UseCases.Comments.Create
{
    public class CreateCommetValidator : AbstractValidator<RequestCreateCommentJson>
    {
        public CreateCommetValidator() {
            RuleFor(x => x.Content)
                .NotEmpty().WithMessage(ResourceMessagesExceptions.CONTENT_NOT_EMPTY)
                .MaximumLength(350).WithMessage(ResourceMessagesExceptions.CONTENT_MAX_LENGTH);
            RuleFor(x => x.ReportId)
                .GreaterThan(0).WithMessage(ResourceMessagesExceptions.REPORTID_INVALID);
        }
    }
}
