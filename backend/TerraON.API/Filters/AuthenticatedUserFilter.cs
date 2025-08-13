using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using TerraON.API.Responses;
using TerraON.Domain.Repositories.Users;
using TerraON.Domain.Security.Tokens;
using TerraON.Exception.ExceptionBase;

namespace TerraON.API.Filters
{
    public class AuthenticatedUserFilter(IAccessTokenValidator accessTokenValidator, IUserReadOnlyRepository userRepository)
        : IAsyncAuthorizationFilter
    {
        private readonly IAccessTokenValidator _accessTokenValidator = accessTokenValidator;
        private readonly IUserReadOnlyRepository _userRepository = userRepository;

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            try
            {
                var token = TokenOnRequest(context);

                Guid userIdentifier = _accessTokenValidator.ValidadeAndGetUserIdentifier(token);

                var exist = await _userRepository.GetByUserIdentifier(userIdentifier)
                    ?? throw new TerraONException("Usuário sem permissão");

                var claims = new List<Claim>
                {
                    new(ClaimTypes.NameIdentifier, userIdentifier.ToString()),
                    new("Id", exist.Id.ToString()),
                    new(ClaimTypes.Name, exist.Name)
                };

                var identity = new ClaimsIdentity(claims, "TarefasCustoms");
                context.HttpContext.User = new ClaimsPrincipal(identity);
            }
            catch (TerraONException ex)
            {
                Console.WriteLine($"AuthenticatedUserFilter - {ex.Message}");
                context.Result = new UnauthorizedObjectResult(new ResponseBase
                {
                    StatusCode = 401,
                    Message = "Não autorizado",
                    Data = ex.Message,
                });
            }
            catch (SecurityTokenExpiredException)
            {
                context.Result = new UnauthorizedObjectResult(new ResponseBase
                {
                    StatusCode = 401,
                    Message = "Token expirado"
                });
            }
            catch (System.Exception ex)
            {
                Console.WriteLine($"Unhandled exception in AuthenticatedUserFilter: {ex.GetType().Name} - {ex.Message}");
                throw;
            }
        }

        private static string TokenOnRequest(AuthorizationFilterContext context)
        {
            var authentication = context.HttpContext.Request.Headers.Authorization.ToString();

            if (string.IsNullOrWhiteSpace(authentication) || !authentication.StartsWith("Bearer "))
            {
                throw new TerraONException("Token não está presente na requisição");
            }

            var token = authentication["Bearer ".Length..].Trim();
            if (string.IsNullOrEmpty(token))
            {
                throw new TerraONException("Token não está presente na requisição");
            }

            return token;
        }
    }
}