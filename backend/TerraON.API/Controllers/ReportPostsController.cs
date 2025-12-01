using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using TerraON.API.Attributes;
using TerraON.API.Responses;
using TerraON.Application.UseCases.ReportPosts.Create;
using TerraON.Application.UseCases.ReportPosts.Create.DTOs;

namespace TerraON.API.Controllers
{
    [AuthenticatedUser]
    public class ReportPostsController : BaseController
    {
        [HttpPost]
        [ProducesResponseType(typeof(ResponseBase<string>), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound, Type = typeof(ResponseBase<string>))]
        public async Task<IActionResult> ReportPost(
    [FromServices] ICreateReportPostsUseCase useCase,
    [FromBody] RequestCreateReportPostsJson request)
        {
            // LOG TEMPORÁRIO
            var claimsDebug = HttpContext.User.Claims
                .Select(c => new { c.Type, c.Value })
                .ToList();

            Console.WriteLine("==== TOKEN CLAIMS ====");
            Console.WriteLine(JsonSerializer.Serialize(claimsDebug));
            Console.WriteLine("======================");

            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(userIdClaim, out var userIdentifier))
                return Unauthorized("Identificador do usuário inválido.");

            await useCase.CreateAsync(userIdentifier, request);

            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status201Created,
                Message = "Postagem denunciada com sucesso."
            };
            return Created(string.Empty, response);
        }
    }
}
