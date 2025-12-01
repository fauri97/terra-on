using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Users.HandleActivation
{
    public class HandleUserActivityUseCase(
        IUserReadOnlyRepository userReadOnlyRepository,
        IUserUpdateOnlyRepository userUpdateOnlyRepository,
        IUnityOfWork unityOfWork) : IHandleUserActivityUseCase
    {
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IUserUpdateOnlyRepository _userUpdateOnlyRepository = userUpdateOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;
        public async Task Execute(long UserId)
        {
            var user = await _userReadOnlyRepository.GetById(UserId)
                ?? throw new NotFoundException("Usuário não encontrado.");

            user.IsDeleted = !user.IsDeleted;

            if (user.IsDeleted)
            {
                user.DeletedAt = DateTime.UtcNow;
            }
            else
            {
                user.DeletedAt = null;
            }

            _userUpdateOnlyRepository.Update(user);
            await _unityOfWork.SaveChangesAsync();
        }
    }
}
