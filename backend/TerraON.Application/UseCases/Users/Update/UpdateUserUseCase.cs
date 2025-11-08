using TerraON.Application.Services.Image;
using TerraON.Application.UseCases.Users.Update.DTOs;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories;
using TerraON.Domain.Repositories.Users;
using TerraON.Exception.ExceptionBase;

namespace TerraON.Application.UseCases.Users.Update
{
    public class UpdateUserUseCase(
        IUserReadOnlyRepository userReadOnlyRepository,
        IUserUpdateOnlyRepository userUpdateOnlyRepository,
        IUnityOfWork unityOfWork) : IUpdateUserUseCase
    {
        private readonly IUserReadOnlyRepository _userReadOnlyRepository = userReadOnlyRepository;
        private readonly IUserUpdateOnlyRepository _userUpdateOnlyRepository = userUpdateOnlyRepository;
        private readonly IUnityOfWork _unityOfWork = unityOfWork;

        public async Task Update(long id, RequestUpdateUserJson request)
        {
            var user = await _userReadOnlyRepository.GetById(id)
                ?? throw new NotFoundException("User not found");

            // Strings: só aplica se vier algo não-vazio.
            if (!string.IsNullOrWhiteSpace(request.Name))
                user.Name = request.Name!.Trim();

            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                user.PhoneNumber = request.PhoneNumber!.Trim();

            if (!string.IsNullOrWhiteSpace(request.City))
                user.City = request.City!.Trim();

            if (!string.IsNullOrWhiteSpace(request.State))
                user.State = request.State!.Trim();

            // Imagem de perfil
            if (!string.IsNullOrWhiteSpace(request.Base64ProfileImage))
            {
                if (!Base64ToByteaService.TryDecode(request.Base64ProfileImage!, out var data, out var contentType, out var sizeBytes))
                    throw new BusinessValidationException(["Imagem de perfil inválida (Base64 corrompido)."]);

                var sha = Base64ToByteaService.ComputeSha256Hex(data);
                var ext = (contentType.Split('/').LastOrDefault() ?? "bin").ToLowerInvariant();
                var fileName = $"{sha[..8]}.{ext}";

                if (user.ProfileImage is null)
                {
                    user.ProfileImage = new Image
                    {
                        Data = data,
                        ContentType = contentType,
                        SizeBytes = sizeBytes,
                        Sha256 = sha,
                        OriginalFileName = fileName
                    };
                }
                else
                {
                    user.ProfileImage.Data = data;
                    user.ProfileImage.ContentType = contentType;
                    user.ProfileImage.SizeBytes = sizeBytes;
                    user.ProfileImage.Sha256 = sha;
                    user.ProfileImage.OriginalFileName = fileName;
                }
            }

            _userUpdateOnlyRepository.Update(user);
            await _unityOfWork.SaveChangesAsync();
        }
    }
}
