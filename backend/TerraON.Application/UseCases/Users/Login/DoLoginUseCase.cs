using TerraON.Application.Services.Cryptography;
using TerraON.Application.UseCases.Users.Login.DTOs;
using TerraON.Domain.Repositories.Users;
using TerraON.Domain.Security.Tokens;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Users.Login
{
    public class DoLoginUseCase(
        IUserReadOnlyRepository userReadOnlyRepository,
        IAccessTokenGenerator accessTokenGenerator,
        IPasswordService passwordService) : IDoLoginUseCase
    {
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IAccessTokenGenerator _accessTokenGenerator = accessTokenGenerator;
        private readonly IPasswordService _passwordService = passwordService;
        public async Task<ResponseLoginJson> Execute(RequestLoginJson dto)
        {
            var user = await _userReadOnlyRepository.GetByEmail(dto.Email)
            ?? throw new LoginException("Usuário ou senha incorreto, tente novamente");

            var verifiedPassword = _passwordService.Verify(dto.Password, user.PasswordHash);

            if (!verifiedPassword)
                throw new LoginException("Usuário ou senha incorreto, tente novamente");

            return new ResponseLoginJson
            {
                Email = dto.Email,
                Name = user.Name,
                AccessToken = _accessTokenGenerator.Generate(user)
            };
        }
    }
}
