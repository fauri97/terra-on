using TerraON.Application.UseCases.Users.Get.All.DTOs;

namespace TerraON.Application.UseCases.Users.Get.All
{
    public interface IGetUsersUseCase
    {
        Task<List<ResponseGetAllUsersJson>> ExecuteAsync();
    }
}
