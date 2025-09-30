namespace TerraON.API.Responses
{
    public class ResponseBase<T>
    {
        public int StatusCode { get; set; }
        public string? Message { get; set; } = string.Empty;
        public T? Data { get; set; }
    }
}
