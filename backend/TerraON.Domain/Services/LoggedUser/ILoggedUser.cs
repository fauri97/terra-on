using TerraON.Domain.Entities;

namespace TerraON.Domain.Services.LoggedUser
{
    public interface ILoggedUser
    {
        public Task<User> User();
    }
}
