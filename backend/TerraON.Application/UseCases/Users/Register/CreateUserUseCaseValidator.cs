using FluentValidation;
using TerraON.Application.UseCases.Users.Register.DTOs;
using TerraON.Exception;

namespace TerraON.Application.UseCases.Users.Register
{
    public class CreateUserUseCaseValidator : AbstractValidator<RequestCreateUserJson>
    {
        public CreateUserUseCaseValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage(ResourceMessagesExceptions.NAME_EMPTY)
                .MaximumLength(120).WithMessage(ResourceMessagesExceptions.NAME_TOO_LONG);

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage(ResourceMessagesExceptions.EMAIL_EMPTY)
                .EmailAddress().WithMessage(ResourceMessagesExceptions.EMAIL_INVALID);

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage(ResourceMessagesExceptions.PASSWORD_EMPTY)
                .MinimumLength(6).WithMessage(ResourceMessagesExceptions.PASSWORD_INVALID);

            RuleFor(x => x.PhoneNumber)
                .Matches(@"^\+?[1-9]\d{1,14}$").When(x => !string.IsNullOrEmpty(x.PhoneNumber))
                .WithMessage(ResourceMessagesExceptions.PHONE_NUMBER_INVALID);
        }
    }
}
