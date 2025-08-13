namespace TerraON.Domain.Security.Tokens
{
    public interface IAccessTokenValidator
    {
        public Guid ValidadeAndGetUserIdentifier(string token);
    }
}