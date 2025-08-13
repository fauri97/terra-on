using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using TerraON.Domain.Security.Tokens;

namespace TerraON.Infrastructure.Security.Tokens.Access
{
    public class JwtTokenValidator(string signingKey) : JwtTokenHandler, IAccessTokenValidator
    {
        private readonly string _signingKey = signingKey;

        public Guid ValidadeAndGetUserIdentifier(string token)
        {
            var validationParameters = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidateIssuer = false,
                IssuerSigningKey = SecurityKey(_signingKey),
                ClockSkew = new TimeSpan(0)
            };
            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, validationParameters, out _);

            var userIdentifier = principal.Claims.First(c => c.Type == ClaimTypes.Sid).Value;

            return Guid.Parse(userIdentifier);
        }

    }
}
