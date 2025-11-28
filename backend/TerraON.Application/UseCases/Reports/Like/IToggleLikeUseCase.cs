namespace TerraON.Application.UseCases.Reports.Like
{
    public interface IToggleLikeUseCase
    {
        public Task<bool> ExecuteAsync(long reportId, long userId);
    }
}
