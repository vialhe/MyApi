namespace MyApi.Services.Firebase
{
    public interface IFirebasePushService
    {
        Task<FirebasePushResult> SendToTokenAsync(
            FirebasePushRequest request,
            CancellationToken cancellationToken = default);

        Task<List<FirebasePushResult>> SendToTokensAsync(
            List<string> tokens,
            FirebasePushRequest request,
            CancellationToken cancellationToken = default);
    }
}