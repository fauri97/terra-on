using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Application.UseCases.Reports.Like
{
    public class ToggleLikeUseCase(
        ILikeRepository likeRepository,
        IUnityOfWork unityOfWork) : IToggleLikeUseCase
    {
        private readonly ILikeRepository _likeRepository = likeRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public async Task<bool> ExecuteAsync(long reportId, long userId)
        {
            var like = await _likeRepository.GetLike(reportId, userId);

            if (like == null)
            {
                Domain.Entities.Like newLike = new()
                {
                    ReportId = reportId,
                    UserId = userId,
                };

                await _likeRepository.Like(newLike);
                await _unityOfWork.SaveChangesAsync();
                return true;
            }
            else
            {
                _likeRepository.Dislike(like);
                await _unityOfWork.SaveChangesAsync();
                return true;
            }
        }
    }
}
