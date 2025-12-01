namespace TerraON.Domain.Repositories.Comments
{
    public interface ICommentReadOnlyRepository
    {
        public Task<int> GetTotalCommentsAsync();
    }
}
