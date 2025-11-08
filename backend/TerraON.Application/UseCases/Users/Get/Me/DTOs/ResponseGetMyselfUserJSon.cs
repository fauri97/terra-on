namespace TerraON.Application.UseCases.Users.Get.Me.DTOs
{
    public class ResponseGetMyselfUserJSon
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Base64ProfileImage { get; set; } = string.Empty;
    }
}
