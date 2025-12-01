namespace TerraON.Application.UseCases.Users.Login.DTOs
{
    public class ResponseLoginJson
    {
        public long Id { get; set; }
        public string? Name { get; set; }
        public string? Email { get; set; }
        public string? AccessToken { get; set; }
        public string? AvatarBase64 { get; set; }
        public string? Role { get; set; }
    }
}
