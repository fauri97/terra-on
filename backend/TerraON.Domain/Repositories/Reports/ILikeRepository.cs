using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Reports
{
    public interface ILikeRepository
    {
        Task<Like?> GetLike(long reportId, long userId);
        Task Like(Like entity);
        void Dislike(Like entity);
    }
}
