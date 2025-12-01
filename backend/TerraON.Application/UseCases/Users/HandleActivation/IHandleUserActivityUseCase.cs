namespace TerraON.Application.UseCases.Users.HandleActivation
{
    public interface IHandleUserActivityUseCase
    {
        public Task Execute(long UserId);
    }
}
