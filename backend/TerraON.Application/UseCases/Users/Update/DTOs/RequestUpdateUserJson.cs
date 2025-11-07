namespace TerraON.Application.UseCases.Users.Update.DTOs
{
    public class RequestUpdateUserJson
    {
        public string Name { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string Base64ProfileImage { get; set; } = string.Empty;
    }
}
