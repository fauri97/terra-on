using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using TerraON.API.Responses;
using TerraON.Domain.Repositories.Users;
using TerraON.Domain.Security.Tokens;
using TerraON.Exception.ExceptionBase;

namespace TerraON.API.Filters
{
    // Registre via services.AddScoped<AuthenticatedUserFilter>();
    public class AuthenticatedUserFilter : IAsyncAuthorizationFilter
    {
        private const string AuthScheme = "Bearer";
        private readonly IAccessTokenValidator _accessTokenValidator;
        private readonly IUserReadOnlyRepository _userRepository;
        private readonly ILogger<AuthenticatedUserFilter> _logger;

        public AuthenticatedUserFilter(
            IAccessTokenValidator accessTokenValidator,
            IUserReadOnlyRepository userRepository,
            ILogger<AuthenticatedUserFilter> logger)
        {
            _accessTokenValidator = accessTokenValidator;
            _userRepository = userRepository;
            _logger = logger;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            try
            {
                var token = ExtractBearerToken(context)
                            ?? throw new TerraONException("Token não está presente na requisição");

                // Confere assinatura/expiração e extrai o identificador do usuário
                Guid userIdentifier = _accessTokenValidator.ValidadeAndGetUserIdentifier(token);

                // Verifica existência/autorização do usuário
                var user = await _userRepository.GetByUserIdentifier(userIdentifier);
                if (user is null)
                {
                    // 403: token ok, mas usuário não tem permissão/registro
                    context.Result = new ObjectResult(new ResponseBase<string>
                    {
                        StatusCode = StatusCodes.Status403Forbidden,
                        Message = "Acesso negado",
                        Data = "Usuário sem permissão"
                    })
                    { StatusCode = StatusCodes.Status403Forbidden };
                    return;
                }

                var claims = new List<Claim>
                {
                    new(ClaimTypes.NameIdentifier, userIdentifier.ToString()),
                    new("Id", user.Id.ToString()),
                    new(ClaimTypes.Name, user.Name)
                    // adicione roles/tenant/etc se desejar:
                    // new(ClaimTypes.Role, "Admin")
                };

                // AuthType apenas descritivo; pode usar "Bearer" para consistência
                var identity = new ClaimsIdentity(claims, AuthScheme);
                context.HttpContext.User = new ClaimsPrincipal(identity);

                // útil pra handlers/serviços sem precisar reparsear claims
                context.HttpContext.Items["UserIdentifier"] = userIdentifier;
            }
            catch (TerraONException ex)
            {
                _logger.LogWarning(ex, "Falha de autorização (domínio).");
                context.Result = new UnauthorizedObjectResult(new ResponseBase<string>
                {
                    StatusCode = StatusCodes.Status401Unauthorized,
                    Message = "Não autorizado",
                    Data = ex.Message
                });
            }
            catch (SecurityTokenExpiredException ex)
            {
                _logger.LogInformation(ex, "Token expirado.");
                context.HttpContext.Response.Headers["WWW-Authenticate"] =
                    $"{AuthScheme} error=\"invalid_token\", error_description=\"token expired\"";

                context.Result = new UnauthorizedObjectResult(new ResponseBase<string>
                {
                    StatusCode = StatusCodes.Status401Unauthorized,
                    Message = "Token expirado",
                    Data = "O token de acesso expirou. Faça login novamente."
                });
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Token inválido.");
                context.HttpContext.Response.Headers["WWW-Authenticate"] =
                    $"{AuthScheme} error=\"invalid_token\", error_description=\"invalid signature or malformed token\"";

                context.Result = new UnauthorizedObjectResult(new ResponseBase<string>
                {
                    StatusCode = StatusCodes.Status401Unauthorized,
                    Message = "Token inválido",
                    Data = "Assinatura inválida ou token malformado."
                });
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Erro inesperado no AuthenticatedUserFilter.");
                // Deixa propagar (gera 500) ou padronize um ProblemDetails aqui, se preferir
                throw;
            }
        }

        private static string? ExtractBearerToken(AuthorizationFilterContext context)
        {
            var auth = context.HttpContext.Request.Headers.Authorization.ToString();
            if (string.IsNullOrWhiteSpace(auth) || !auth.StartsWith($"{AuthScheme} ", StringComparison.OrdinalIgnoreCase))
                return null;

            var token = auth.Substring($"{AuthScheme} ".Length).Trim();
            return string.IsNullOrEmpty(token) ? null : token;
        }
    }
}
