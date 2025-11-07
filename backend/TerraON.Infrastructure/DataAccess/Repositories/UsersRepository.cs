using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Users;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class UsersRepository(TerraONDbContext dbContext) :
        IUserReadOnlyRepository,
        IUserWriteOnlyRepository,
        IUserUpdateOnlyRepository
    {
        private readonly TerraONDbContext _dbContext = dbContext;

        public async Task CreateAsync(User user)
            => await _dbContext.Users.AddAsync(user);

        public async Task<User?> GetById(long id)
            => await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == id);
        public async Task<User?> GetByEmail(string email)
            => await _dbContext.Users
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Email == email);

        public async Task<bool> ExistActiveUserWithEmail(string email)
            => await _dbContext.Users
                .AsNoTracking()
                .AnyAsync(u => u.Email == email && !u.IsDeleted);

        public async Task<User?> GetByUserIdentifier(Guid userIdentifier)
           
            => await _dbContext.Users   
                .AsNoTracking()
                .Include(img => img.ProfileImage)
                .FirstOrDefaultAsync(u => u.UserIdentifier == userIdentifier);

        public async Task<bool> ExistActiveUserWithID(long id)
            => await _dbContext.Users
                .AsNoTracking()
                .AnyAsync(u => u.Id == id && !u.IsDeleted);

        public void Update(User user)
            => _dbContext.Users.Update(user);
    }
}
