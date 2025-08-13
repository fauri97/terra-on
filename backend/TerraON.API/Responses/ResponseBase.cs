namespace TerraON.API.Responses
{
    public class ResponseBase
    {
        public int StatusCode { get; set; }
        public string? Message { get; set; } = string.Empty;
        public object? Data { get; set; }
    }
}
