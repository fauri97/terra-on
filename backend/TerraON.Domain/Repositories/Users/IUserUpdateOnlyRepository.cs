namespace TerraON.Domain.Repositories.Users
{
    public interface IUserUpdateOnlyRepository
    {
        public void Update(Entities.User user);
    }
}
