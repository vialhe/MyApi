using FirebaseAdmin.Messaging;

namespace MyApi.Services.Firebase
{
    public class FirebasePushService : IFirebasePushService
    {
        private readonly ILogger<FirebasePushService> _logger;

        public FirebasePushService(ILogger<FirebasePushService> logger)
        {
            _logger = logger;
        }

        public async Task<FirebasePushResult> SendToTokenAsync(
            FirebasePushRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Token))
                    throw new Exception("El token FCM es requerido.");

                if (string.IsNullOrWhiteSpace(request.Titulo))
                    throw new Exception("El título de la notificación es requerido.");

                if (string.IsNullOrWhiteSpace(request.Mensaje))
                    throw new Exception("El mensaje de la notificación es requerido.");

                var data = request.Data ?? new Dictionary<string, string>();

                data["tipoNotificacion"] = request.TipoNotificacion ?? "";
                data["referenciaTipo"] = request.ReferenciaTipo ?? "";
                data["referenciaId"] = request.ReferenciaId ?? "";

                var message = new Message
                {
                    Token = request.Token,

                    Notification = new Notification
                    {
                        Title = request.Titulo,
                        Body = request.Mensaje,
                        ImageUrl = request.ImagenUrl
                    },

                    Data = data,

                    Android = new AndroidConfig
                    {
                        Priority = Priority.High,
                        Notification = new AndroidNotification
                        {
                            Sound = "default",
                            ChannelId = "appointments"
                        }
                    },

                    Apns = new ApnsConfig
                    {
                        Headers = new Dictionary<string, string>
                        {
                            { "apns-priority", "10" }
                        },
                        Aps = new Aps
                        {
                            Sound = "default",
                            ContentAvailable = true
                        }
                    }
                };

                var response = await FirebaseMessaging.DefaultInstance.SendAsync(
                    message,
                    cancellationToken);

                return new FirebasePushResult
                {
                    Success = true,
                    Token = request.Token,
                    MessageId = response
                };
            }
            catch (FirebaseMessagingException ex)
            {
                _logger.LogError(
                    ex,
                    "Error Firebase enviando push al token {Token}",
                    request.Token);

                return new FirebasePushResult
                {
                    Success = false,
                    Token = request.Token,
                    Error = $"{ex.MessagingErrorCode}: {ex.Message}"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Error general enviando push al token {Token}",
                    request.Token);

                return new FirebasePushResult
                {
                    Success = false,
                    Token = request.Token,
                    Error = ex.Message
                };
            }
        }

        public async Task<List<FirebasePushResult>> SendToTokensAsync(
            List<string> tokens,
            FirebasePushRequest request,
            CancellationToken cancellationToken = default)
        {
            var results = new List<FirebasePushResult>();

            foreach (var token in tokens.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
            {
                var pushRequest = new FirebasePushRequest
                {
                    Token = token,
                    Titulo = request.Titulo,
                    Mensaje = request.Mensaje,
                    ImagenUrl = request.ImagenUrl,
                    TipoNotificacion = request.TipoNotificacion,
                    ReferenciaTipo = request.ReferenciaTipo,
                    ReferenciaId = request.ReferenciaId,
                    Data = request.Data
                };

                var result = await SendToTokenAsync(pushRequest, cancellationToken);

                results.Add(result);
            }

            return results;
        }
    }
}