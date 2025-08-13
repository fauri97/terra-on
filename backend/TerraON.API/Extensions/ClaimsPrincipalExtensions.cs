using System.Security.Claims;

namespace TerraON.API.Extensions
{
    public static class ClaimsPrincipalExtensions
    {
        public static long GetUserId(this ClaimsPrincipal user)
        {
            var id = user.FindFirstValue("Id");
            return long.TryParse(id, out var userId)
                ? userId
                : throw new UnauthorizedAccessException("Id do usuário inválido");
        }
    }
}