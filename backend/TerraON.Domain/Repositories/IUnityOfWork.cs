namespace TerraON.Domain.Repositories
{
    public interface IUnityOfWork
    {
        public Task SaveChangesAsync();

        public void Dispose();
    }
}
