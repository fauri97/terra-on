using TerraON.Application.UseCases.Users.Register.DTOs;

namespace TerraON.Application.UseCases.Users.Register
{
    public interface ICreateUserUseCase
    {
        public Task<ResponseCreatedUserJson> ExecuteAsync(RequestCreateUserJson request);
    }
}
