using TerraON.Application.UseCases.ReportPosts.Create.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.ReportPosts;
using TerraON.Domain.Repositories.Reports;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.ReportPosts.Create
{
    public class CreateReportPostsUseCase(
        IReportPostsWriteOnlyRepository reportPostsWriteOnlyRepository,
        IUserReadOnlyRepository userReadOnlyRepository,
        IReportReadOnlyRepository reportReadOnlyRepository,
        IUnityOfWork unityOfWork) : ICreateReportPostsUseCase
    {
        private readonly IReportPostsWriteOnlyRepository _reportPostsWriteOnlyRepository = reportPostsWriteOnlyRepository;
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IReportReadOnlyRepository _reportReadOnlyRepository = reportReadOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public async Task CreateAsync(Guid userIndetification, RequestCreateReportPostsJson request)
        {
            var user = await _userReadOnlyRepository.GetByUserIdentifier(userIndetification)
                ?? throw new NotFoundException("User not found");

            var exist = await _reportReadOnlyRepository.ExistsByIdAsync(request.PostId);
            if (!exist) throw new NotFoundException("Post not found");

            Console.WriteLine("Creating report post...");
            Console.WriteLine($"User ID: {user.Id}, Post ID: {request.PostId}, Reason: {request.Reason}");

            ReportPost newReportPosts = new()
            {
                ReportId = request.PostId,
                Reason = request.Reason,
                UserId = user.Id,
            };

            await _reportPostsWriteOnlyRepository.AddAsync(newReportPosts);
            await _unityOfWork.SaveChangesAsync();
        }
    }
}
