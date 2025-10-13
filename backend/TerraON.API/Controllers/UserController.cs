using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Users.Register;
using TerraON.Application.UseCases.Users.Register.DTOs;
using TerraON.Exception.ExceptionBase;

namespace TerraON.API.Controllers
{
    public class UserController : BaseController
    {
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ResponseBase<ResponseCreatedUserJson>))]
        [ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<ResponseCreatedUserJson>>> Register(
            [FromServices] ICreateUserUseCase useCase,
            [FromBody] RequestCreateUserJson request)
        { 
            // Supondo que seu use case retorne o DTO do usuário criado
            var created = await useCase.ExecuteAsync(request);

            var response = new ResponseBase<ResponseCreatedUserJson>
            {
                StatusCode = StatusCodes.Status201Created,
                Message = "Usuário criado com sucesso.",
                Data = created
            };

            // Você pode usar Created(string.Empty, response) ou CreatedAtAction se tiver rota de GET por id
            return Created(string.Empty, response);
        }
    }
}
