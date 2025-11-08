namespace TerraON.Application.UseCases.Users.Get.Me
{
    public interface IGetMyselfUserUseCase
    {
        Task<DTOs.ResponseGetMyselfUserJSon> ExecuteAsync(Guid userIdentifier);
    }
}
