using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Reports.Create;
using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Application.UseCases.Reports.Get;
using TerraON.Application.UseCases.Reports.Get.DTOs;

namespace TerraON.API.Controllers
{
    public class ReportController : BaseController
    {

        /// <summary>
        /// Cria uma novo denúncia.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ResponseBase<string>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<string>>> Create(
            [FromServices] ICreateReportUseCase useCase,
            [FromBody] RequestCreateReportJson request)
        {
            await useCase.ExecuteAsync(request);

            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status201Created,
                Message = "Relatório criado com sucesso.",
                Data = "OK"
            };

            return Created(string.Empty, response);
        }

        /// <summary>
        /// Retorna todos as denúncias cadastrados.
        /// </summary>
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ResponseBase<List<ResponseGetReportJson>>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<List<ResponseGetReportJson>>>> GetAll(
            [FromServices] IGetReportUseCase useCase)
        {
            var reports = await useCase.ExecuteAsync();

            var response = new ResponseBase<List<ResponseGetReportJson>>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = reports.Count > 0
                    ? "Relatórios encontrados com sucesso."
                    : "Nenhum relatório encontrado.",
                Data = reports
            };

            return Ok(response);
        }
    }
}
