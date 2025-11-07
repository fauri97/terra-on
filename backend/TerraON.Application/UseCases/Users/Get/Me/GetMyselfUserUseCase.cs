using TerraON.Application.UseCases.Users.Get.Me.DTOs;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Users.Get.Me
{
    public class GetMyselfUserUseCase (IUserReadOnlyRepository userReadOnlyRepository) : IGetMyselfUserUseCase
    {
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        public async Task<ResponseGetMyselfUserJSon> ExecuteAsync(Guid userIdentifier)
        {
            var user = await _userReadOnlyRepository.GetByUserIdentifier(userIdentifier)
                ?? throw new NotFoundException(ResourceMessagesExceptions.USER_NOT_FOUND);

            ResponseGetMyselfUserJSon response = new ResponseGetMyselfUserJSon
            {
                Id = user.Id,
                City = user.City ?? "N/A",
                State = user.State ?? "N/A",
                Email = user.Email,
                Name = user.Name,
                PhoneNumber = user.PhoneNumber ?? "N/A",
                Base64ProfileImage = user.ProfileImage != null
                    ? Convert.ToBase64String(user.ProfileImage.Data)
                    : string.Empty
            };

            return response;
        }
    }
}
