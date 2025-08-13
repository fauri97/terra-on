using TerraON.Domain.Entities;

namespace TerraON.Domain.Security.Tokens
{
    public interface IAccessTokenGenerator
    {
        public string Generate(User user);
    }
}
