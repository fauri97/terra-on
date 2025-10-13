using Microsoft.AspNetCore.Mvc;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Comments.Create;
using TerraON.Application.UseCases.Comments.Create.DTOs;

namespace TerraON.API.Controllers
{
    public class CommentController : BaseController
    {
        /// <summary>
        /// Cria um novo comentário para uma denúncia.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<string>>> Create(
            [FromServices] ICreateCommentUseCase useCase,
            [FromBody] RequestCreateCommentJson request)
        {
            await useCase.Execute(request);

            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status201Created,
                Message = "Comentário criado com sucesso.",
                Data = "OK"
            };

            return Created(string.Empty, response);
        }
    }
}
