namespace TerraON.Application.UseCases.Users.Register.DTOs
{
    public class RequestCreateUserJson
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? PhoneId { get; set; }
    }
}
