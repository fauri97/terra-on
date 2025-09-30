using TerraON.API.Responses;
using TerraON.Exception.ExceptionBase;

namespace TerraON.API.Middlewares
{
    public class ErrorHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ErrorHandlingMiddleware> _logger;

        public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task Invoke(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (BusinessValidationException ex)
            {
                _logger.LogWarning(ex, "Erro de negócio");
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                context.Response.ContentType = "application/json";

                var payload = new ResponseBase<string>
                {
                    StatusCode = StatusCodes.Status400BadRequest,
                    Message = "Erro de validação de negócio",
                    Data = ex.Message // apenas a mensagem
                };

                await context.Response.WriteAsJsonAsync(payload);
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Erro inesperado");
                context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                context.Response.ContentType = "application/json";

                var payload = new ResponseBase<string>
                {
                    StatusCode = StatusCodes.Status500InternalServerError,
                    Message = "Erro interno",
                    Data = "Ocorreu um erro inesperado."
                };

                await context.Response.WriteAsJsonAsync(payload);
            }
        }
    }

}
