namespace MyApi.Services.Notificaciones
{
    public class NotificacionBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<NotificacionBackgroundService> _logger;

        public NotificacionBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<NotificacionBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Servicio de notificaciones iniciado.");

            using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await timer.WaitForNextTickAsync(stoppingToken);

                    using var scope = _serviceProvider.CreateScope();

                    var worker = scope.ServiceProvider
                        .GetRequiredService<INotificacionWorkerService>();

                    await worker.ProcesarNotificacionesPendientesAsync(stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error ejecutando servicio de notificaciones.");
                }
            }

            _logger.LogInformation("Servicio de notificaciones detenido.");
        }
    }
}