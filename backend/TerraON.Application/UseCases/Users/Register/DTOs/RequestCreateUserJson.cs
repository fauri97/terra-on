namespace TerraON.Application.UseCases.Users.Register.DTOs
{
    public class RequestCreateUserJson
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? PhoneId { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? ProfileImageBase64 { get; set; }
    }
}
