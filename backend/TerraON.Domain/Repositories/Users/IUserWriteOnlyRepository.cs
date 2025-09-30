using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Users
{
    public interface IUserWriteOnlyRepository
    {
        public Task CreateAsync(User user);
    }
}
