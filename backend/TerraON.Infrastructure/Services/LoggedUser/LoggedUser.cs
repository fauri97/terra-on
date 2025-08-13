using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using TerraON.Domain.Entities;
using TerraON.Domain.Security.Tokens;
using TerraON.Domain.Services.LoggedUser;
using TerraON.Infrastructure.DataAccess;

namespace TerraON.Infrastructure.Services.LoggedUser
{
    public class LoggedUser(TerraONDbContext context, ITokenProvider tokenProvider) : ILoggedUser
    {
        private readonly TerraONDbContext _context = context;
        private readonly ITokenProvider _tokenProvider = tokenProvider;

        public async Task<User> User()
        {
            var token = _tokenProvider.Value();
            var tokenHandler = new JwtSecurityTokenHandler();

            var jwtSecurityToken = tokenHandler.ReadJwtToken(token);

            var identifier = jwtSecurityToken.Claims.First(c => c.Type == ClaimTypes.Sid).Value;
            var userIdentifier = Guid.Parse(identifier);

            return await _context
                .Users
                .AsNoTracking()
                .FirstAsync(user => user.UserIdentifier == userIdentifier);
        }
    }
}
