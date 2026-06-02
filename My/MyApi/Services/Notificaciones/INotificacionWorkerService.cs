namespace MyApi.Services.Notificaciones
{
    public interface INotificacionWorkerService
    {
        Task ProcesarNotificacionesPendientesAsync(CancellationToken cancellationToken = default);
    }
}