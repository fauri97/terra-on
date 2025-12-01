using TerraON.Domain.Repositories.Users;

namespace TerraON.Application.UseCases.Users.Get.All
{
    public class GetUsersUseCase(IUserReadOnlyRepository userReadOnlyRepository) : IGetUsersUseCase
    {
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        public async Task<List<DTOs.ResponseGetAllUsersJson>> ExecuteAsync()
        {
            var users = await _userReadOnlyRepository.GetAllUsersAsync();
            var response = users.Select(user => new DTOs.ResponseGetAllUsersJson
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                City = user.City ?? string.Empty,
                State = user.State ?? string.Empty,
                PhoneNumber = user.PhoneNumber ?? string.Empty,
                Base64ProfileImage = user.ProfileImage != null
                    ? Convert.ToBase64String(user.ProfileImage.Data)
                    : string.Empty,
                Role = user.Role.ToString(),
                IsDeactivated = user.IsDeleted,
            }).ToList();
            return response;
        }
    }
}
