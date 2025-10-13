using Microsoft.AspNetCore.Mvc;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Users.Login;
using TerraON.Application.UseCases.Users.Login.DTOs;

namespace TerraON.API.Controllers
{
    public class LoginController : BaseController
    {
        [HttpPost]
        [ProducesResponseType(typeof(ResponseBase<ResponseLoginJson>), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<IActionResult> Login(
            [FromServices] IDoLoginUseCase useCase,
            [FromBody] RequestLoginJson request)
        {
            var result = await useCase.Execute(request);

            var response = new ResponseBase<ResponseLoginJson>
            {
                StatusCode = StatusCodes.Status201Created,
                Message = "Usuário logado com sucesso.",
                Data = result
            };
            return Created(string.Empty, response);
        }
    }
}
