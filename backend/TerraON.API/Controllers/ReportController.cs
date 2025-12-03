using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TerraON.API.Attributes;
using TerraON.API.Responses;
using TerraON.Application.UseCases.Reports.ChangeStatus;
using TerraON.Application.UseCases.Reports.ChangeStatus.DTOs;
using TerraON.Application.UseCases.Reports.Create;
using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Application.UseCases.Reports.ExportPdf;
using TerraON.Application.UseCases.Reports.ExportPdf.DTOs;
using TerraON.Application.UseCases.Reports.Get;
using TerraON.Application.UseCases.Reports.Get.DTOs;
using TerraON.Application.UseCases.Reports.Like;

namespace TerraON.API.Controllers
{
    public class ReportController : BaseController
    {

        /// <summary>
        /// Cria uma novo denúncia.
        /// </summary>
        [AuthenticatedUser]
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

        /// <summary>  
        /// Retorna todas as denúncias cadastrados pelo usuário autenticado.
        /// </summary>
        [AuthenticatedUser]
        [HttpGet("mine")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ResponseBase<List<ResponseGetReportJson>>))]
        [ProducesResponseType(StatusCodes.Status500InternalServerError, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<List<ResponseGetReportJson>>>> GetMyReports(
            [FromServices] IGetReportUseCase useCase)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(userIdClaim, out var userIdentifier))
                return Unauthorized("Identificador do usuário inválido.");


            var reports = await useCase.GetMyReports(userIdentifier);
            var response = new ResponseBase<List<ResponseGetReportJson>>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = reports.Count > 0
                    ? "Seus relatórios foram encontrados com sucesso."
                    : "Você não possui relatórios cadastrados.",
                Data = reports
            };
            return Ok(response);
        }

        [AuthenticatedUser]
        [HttpPost("{reportId}/user/{userId}/like")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<string>>> ToggleLike(
            [FromServices] IToggleLikeUseCase useCase,
            [FromRoute] long reportId,
            [FromRoute] long userId)
        {
            await useCase.ExecuteAsync(reportId, userId);
            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = "Operação de like/dislike realizada com sucesso.",
                Data = "OK"
            };
            return Ok(response);
        }

        [AuthenticatedUser]
        [HttpPut("{reportId}/status")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(ResponseBase<string>))]
        public async Task<ActionResult<ResponseBase<string>>> ChangeStatus(
            [FromServices] IChangeStatusUseCase useCase,
            [FromRoute] long reportId,
            [FromBody] RequestReportNewStatusJson request)
        {
            await useCase.ExecuteAsync(reportId, request);
            var response = new ResponseBase<string>
            {
                StatusCode = StatusCodes.Status200OK,
                Message = "Status do relatório alterado com sucesso.",
                Data = "OK"
            };
            return Ok(response);
        }

        [AuthenticatedUser]
        [HttpGet("export/pdf")]
        [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(FileContentResult))]
        public async Task<ActionResult> ExportReportsToPdf(
            [FromServices] IExportReportsPdfUseCase useCase,
            [FromQuery] string? status,
            [FromQuery] string? city,
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to)
        {
            var filter = new ExportPDFFilter
            {
                Status = status,
                City = city,
                From = from,
                To = to
            };

            var pdfBytes = await useCase.ExecuteAsync(filter);

            var fileResult = new FileContentResult(pdfBytes, "application/pdf")
            {
                FileDownloadName = $"relatorios-denuncias-{DateTime.UtcNow:yyyyMMddHHmmss}.pdf"
            };

            return fileResult;
        }
    }
}
