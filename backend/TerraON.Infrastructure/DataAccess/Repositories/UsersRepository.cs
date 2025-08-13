using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Users;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class UsersRepository(TerraONDbContext dbContext) : IUserReadOnlyRepository
    {
        private readonly TerraONDbContext _dbContext = dbContext;
        public async Task<User?> GetById(long id)
            => await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == id);

        public async Task<User?> GetByUserIdentifier(Guid userIdentifier)
           
            => await _dbContext.Users   
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserIdentifier == userIdentifier);
    }
}
