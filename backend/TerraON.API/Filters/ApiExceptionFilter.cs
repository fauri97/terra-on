using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using TerraON.Exception.ExceptionBase;

namespace TerraON.API.Filters
{
    public class ApiExceptionFilter : IExceptionFilter
    {
        private readonly ILogger<ApiExceptionFilter> _logger;

        public ApiExceptionFilter(ILogger<ApiExceptionFilter> logger)
        {
            _logger = logger;
        }

        public void OnException(ExceptionContext context)
        {
            var exception = context.Exception;
            _logger.LogError(exception, "Unhandled exception: {Message}", exception.Message);

            if (exception is ValidationException validationEx)
            {
                var errors = validationEx.Errors
                    .Select(e => new { Field = e.PropertyName, Error = e.ErrorMessage });

                context.Result = new BadRequestObjectResult(new
                {
                    statusCode = 400,
                    message = "Erro de validação",
                    errors
                });

                context.ExceptionHandled = true;
                return;
            }

            if (exception is BusinessValidationException businessValidation)
            {
                context.Result = new BadRequestObjectResult(new
                {
                    statusCode = 400,
                    message = "Erro de validação de regra de negócio",
                    errors = businessValidation.Errors
                });

                context.ExceptionHandled = true;
                return;
            }

            if (exception is NotFoundException notFoundException)
            {
                context.Result = new NotFoundObjectResult(new
                {
                    statusCode = 404,
                    message = notFoundException.Message
                });
                context.ExceptionHandled = true;
                return;
            }

            if (exception is LoginException loginException)
            {
                context.Result = new BadRequestObjectResult(new
                {
                    statusCode = 401,
                    message = loginException.Message
                });
                context.ExceptionHandled = true;
                return;
            }

            if (exception is TerraONException ex)
            {
                context.Result = new BadRequestObjectResult(new
                {
                    statusCode = 400,
                    message = ex.Message
                });

                context.ExceptionHandled = true;
                return;
            }

            context.Result = new ObjectResult(new
            {
                statusCode = 500,
                message = "Ocorreu um erro inesperado.",
            })
            {
                StatusCode = 500
            };

            context.ExceptionHandled = true;
        }
    }
}
