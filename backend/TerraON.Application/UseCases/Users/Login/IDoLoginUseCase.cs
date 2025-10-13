using TerraON.Application.UseCases.Users.Login.DTOs;

namespace TerraON.Application.UseCases.Users.Login
{
    public interface IDoLoginUseCase
    {
        public Task<ResponseLoginJson> Execute(RequestLoginJson dto);
    }
}
