using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using TerraON.Domain.Entities;
using TerraON.Domain.Security.Tokens;

namespace TerraON.Infrastructure.Security.Tokens.Access
{
    public class JwtTokenGenerator : JwtTokenHandler, IAccessTokenGenerator
    {
        private readonly uint _expirationTimeInMinutes;
        private readonly string _signingKey;

        public JwtTokenGenerator(uint expirationTimeInMinutes, string signingKey)
        {
            _expirationTimeInMinutes = expirationTimeInMinutes;
            _signingKey = signingKey;
        }
        public string Generate(User user)
        {
            var claims = new List<Claim>
            {
                new(ClaimTypes.Sid, user.UserIdentifier.ToString())
            };
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(_expirationTimeInMinutes),
                SigningCredentials = new SigningCredentials(SecurityKey(_signingKey), SecurityAlgorithms.HmacSha256Signature),
            };

            var tokenHandler = new JwtSecurityTokenHandler();

            var securityToken = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(securityToken);
        }
    }
}