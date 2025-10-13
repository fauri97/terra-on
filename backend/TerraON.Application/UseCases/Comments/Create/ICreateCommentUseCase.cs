using TerraON.Application.UseCases.Comments.Create.DTOs;

namespace TerraON.Application.UseCases.Comments.Create
{
    public interface ICreateCommentUseCase
    {
        public Task Execute(RequestCreateCommentJson request);
    }
}
