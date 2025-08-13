using TerraON.Domain.Security.Tokens;

namespace TerraON.API.Token
{
    public class HttpContextTokenValue(IHttpContextAccessor contextAccessor) : ITokenProvider
    {
        private readonly IHttpContextAccessor _ContextAccessor = contextAccessor;
        public string Value()
        {
            var authentication = _ContextAccessor.HttpContext!.Request.Headers.Authorization.ToString();
            return authentication["Bearer ".Length..].Trim();
        }
    }
}
