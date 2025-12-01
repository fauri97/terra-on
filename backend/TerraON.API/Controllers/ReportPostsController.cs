using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using TerraON.API.Attributes;
using TerraON.API.Responses;
using TerraON.Application.UseCases.ReportPosts.Create;
using TerraON.Application.UseCases.ReportPosts.Create.DTOs;
using TerraON.Application.UseCases.ReportPosts.Get;
using TerraON.Application.UseCases.ReportPosts.Get.DTOs;
using TerraON.Application.UseCases.ReportPosts.Update;
using TerraON.Application.UseCases.ReportPosts.Update.DTOs;

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
            var claimsDebug = HttpContext.User.Claims
                .Select(c => new { c.Type, c.Value })
                .ToList();
            Console.WriteLine(JsonSerializer.Serialize(claimsDebug));

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


        [HttpGet]
        [ProducesResponseType(typeof(ResponseBase<List<ResponseGetReportPostsJson>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetReportPosts(
            [FromServices] IGetReportPostsUseCase useCase)
        {
            var reportPosts = await useCase.ExecuteAsync();
            var response = new ResponseBase<List<ResponseGetReportPostsJson>>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = "Denúncias de postagens recuperadas com sucesso.",
                Data = reportPosts
            };
            return Ok(response);
        }

        [HttpPut("{reportPostId}")]
        [ProducesResponseType(typeof(ResponseBase<string>), StatusCodes.Status200OK)]
        public async Task<IActionResult> UpdateReportPostStatus(
            [FromServices] IUpdateReportPostsUseCase useCase,
            [FromRoute] long reportPostId,
            [FromBody] RequestUpdatePostsJson status)
        {
            await useCase.Execute(reportPostId, status);
            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = "Status da denúncia de postagem atualizado com sucesso."
            };
            return Ok(response);
        }
    }
}
