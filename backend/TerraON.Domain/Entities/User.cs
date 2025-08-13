namespace TerraON.Domain.Entities
{
    public class User : EntityBase
    {
        public Guid UserIdentifier { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string NormalizedEmail { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? PhoneId { get; set; }
    }
}
