namespace TerraON.Application.Services.Cryptography
{
    public interface IPasswordService
    {
        string Hash(string plainPassword);
        bool Verify(string plainPassword, string hashedPassword);
    }
}
