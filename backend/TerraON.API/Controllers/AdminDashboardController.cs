using Microsoft.AspNetCore.Mvc;
using TerraON.API.Attributes;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Admin.Dashboard;
using TerraON.Application.UseCases.Admin.Dashboard.DTOs;

namespace TerraON.API.Controllers
{
    [Route("api/admin/dashboard")]
    public class AdminDashboardController : BaseController
    {
        [AuthenticatedUser] // mesmo padrão do seu Create(...)
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ResponseBase<ResponseAdminDashboardJson>))]
        [ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<ResponseAdminDashboardJson>>> Get(
            [FromServices] IGetAdminDashboardUseCase useCase
        )
        {
            var data = await useCase.ExecuteAsync();

            var response = new ResponseBase<ResponseAdminDashboardJson>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = "Dashboard carregado com sucesso.",
                Data = data
            };

            return Ok(response);
        }
    }
}
