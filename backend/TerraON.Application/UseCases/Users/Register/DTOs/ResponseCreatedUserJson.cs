namespace TerraON.Application.UseCases.Users.Register.DTOs
{
    public class ResponseCreatedUserJson
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string AccessToken { get; set; } = string.Empty;
    }
}
