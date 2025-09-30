using TerraON.Domain.Repositories;

namespace TerraON.Infrastructure.DataAccess
{
    public class UnityOfWork (TerraONDbContext context) : IUnityOfWork
    {
        private readonly TerraONDbContext _context = context;
        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
