using TerraON.Domain.Entities;

namespace TerraON.Domain.Repositories.Images
{
    public interface IImageWriteOnlyRepository
    {
        public Task AddAsync(Image image);
        public Task AddRangeAsync(IEnumerable<Image> images);
    }
}
