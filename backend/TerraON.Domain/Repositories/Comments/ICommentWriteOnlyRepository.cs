using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Comments
{
    public interface ICommentWriteOnlyRepository
    {
        public Task AddAsync(Comment comment);
    }
}
