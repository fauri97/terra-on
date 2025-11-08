using TerraON.Application.UseCases.Users.Update.DTOs;

namespace TerraON.Application.UseCases.Users.Update
{
    public interface IUpdateUserUseCase
    {
        Task Update(long id, RequestUpdateUserJson request); 
    }
}
