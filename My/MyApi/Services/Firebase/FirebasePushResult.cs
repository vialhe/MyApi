namespace MyApi.Services.Firebase
{
    public class FirebasePushResult
    {
        public bool Success { get; set; }
        public string Token { get; set; } = string.Empty;
        public string? MessageId { get; set; }
        public string? Error { get; set; }
    }
}