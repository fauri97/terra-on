using Microsoft.EntityFrameworkCore;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Images;

namespace TerraON.Infrastructure.DataAccess.Repositories
{
    public class ImagesRepository(TerraONDbContext context) : IImageWriteOnlyRepository
    {
        private readonly TerraONDbContext _dbContext = context;
        public async Task AddAsync(Image image)
            => await _dbContext.Images.AddAsync(image);

        public async Task AddRangeAsync(IEnumerable<Image> images)
            => await _dbContext.Images.AddRangeAsync(images);
    }
}
