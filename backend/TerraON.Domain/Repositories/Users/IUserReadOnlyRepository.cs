using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Users
{
    public interface IUserReadOnlyRepository
    {
        public Task<User?> GetById(long id);
        public Task<User?> GetByUserIdentifier(Guid userIdentifier);
        public Task<User?> GetByNormalizedEmail(string email);
        public Task<bool> ExistActiveUserWithEmail(string email);
        public Task<bool> ExistActiveUserWithID(long id);
        public Task<IEnumerable<User>> GetAllUsersAsync();
    }
}
