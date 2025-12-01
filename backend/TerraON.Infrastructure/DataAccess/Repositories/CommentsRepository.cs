using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Comments;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    internal class CommentsRepository(TerraONDbContext dbContext) : ICommentWriteOnlyRepository, ICommentReadOnlyRepository
    {
        private readonly TerraONDbContext _dbContext = dbContext;

        public async Task AddAsync(Comment comment)
            => await _dbContext.Comments.AddAsync(comment);

        public async Task<int> GetTotalCommentsAsync()
            => await _dbContext.Comments.CountAsync();
    }
}
