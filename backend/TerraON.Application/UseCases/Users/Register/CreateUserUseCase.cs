using AutoMapper;
using TerraON.Application.Services.Cryptography;
using TerraON.Application.UseCases.Users.Register.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Users;
using TerraON.Domain.Security.Tokens;
using TerraON.Exception;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Users.Register
{
    public class CreateUserUseCase 
        (IUserWriteOnlyRepository userWriteOnlyRepository,
        IUserReadOnlyRepository userReadOnlyRepository,
        IMapper mapper,
        IPasswordService passwordService,
        IAccessTokenGenerator accessTokenGenerator,
        IUnityOfWork unityOfWork)
        : ICreateUserUseCase
    {
        private readonly IUserWriteOnlyRepository _userWriteOnlyRepository = userWriteOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IMapper _mapper = mapper;
        private readonly IPasswordService _passwordService = passwordService;
        private readonly IAccessTokenGenerator _accessTokenGenerator = accessTokenGenerator;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public async Task<ResponseCreatedUserJson> ExecuteAsync(RequestCreateUserJson request)
        {
            await Validate(request);
            var user = _mapper.Map<User>(request);
            user.PasswordHash = _passwordService.Hash(request.Password);
            user.UserIdentifier = Guid.NewGuid();

            await _userWriteOnlyRepository.CreateAsync(user);
            await _unityOfWork.SaveChangesAsync();

            var response = _mapper.Map<ResponseCreatedUserJson>(user);
            response.AccessToken = _accessTokenGenerator.Generate(user);
            return response;
        }

        private async Task Validate(RequestCreateUserJson request)
        {
            var validator = new CreateUserUseCaseValidator();
            var result = validator.Validate(request);

            var emailExist = await _userReadOnlyRepository.ExistActiveUserWithEmail(request.Email);
            if (emailExist)
            {
                result.Errors.Add(new FluentValidation.Results.ValidationFailure(string.Empty, ResourceMessagesExceptions.EMAIL_ALREDY_REGISTERED));
            }


            if (result.IsValid == false)
            {
                var errorMessages = result.Errors.Select(e => e.ErrorMessage);
                throw new BusinessValidationException(errorMessages.ToList());
            }
        }
    }
}
