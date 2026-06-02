using System.Data;
using MyApi.Models.MyDB;
using MyApi.Services.Firebase;

namespace MyApi.Services.Notificaciones
{
    public class NotificacionWorkerService : INotificacionWorkerService
    {
        private readonly IFirebasePushService _firebasePushService;
        private readonly ILogger<NotificacionWorkerService> _logger;

        public NotificacionWorkerService(
            IFirebasePushService firebasePushService,
            ILogger<NotificacionWorkerService> logger)
        {
            _firebasePushService = firebasePushService;
            _logger = logger;
        }

        public async Task ProcesarNotificacionesPendientesAsync(
            CancellationToken cancellationToken = default)
        {
            var dtNotificaciones = ExecuteDataTable(
                "sp_se_notificacionesFCMPendientesEnviar",
                db =>
                {
                    db.AddParameter("@top", 50);
                });

            if (dtNotificaciones.Rows.Count == 0)
                return;

            foreach (DataRow row in dtNotificaciones.Rows)
            {
                if (cancellationToken.IsCancellationRequested)
                    break;

                int idNotificacionFCM = Convert.ToInt32(row["idNotificacionFCM"]);
                int idUsuario = Convert.ToInt32(row["idUsuario"]);

                int? idEntidad = null;

                if (row["idEntidad"] != DBNull.Value)
                    idEntidad = Convert.ToInt32(row["idEntidad"]);

                string titulo = Convert.ToString(row["titulo"]) ?? "";
                string mensaje = Convert.ToString(row["mensaje"]) ?? "";
                string tipoNotificacion = Convert.ToString(row["tipoNotificacion"]) ?? "";
                string referenciaTipo = Convert.ToString(row["referenciaTipo"]) ?? "";
                string referenciaId = Convert.ToString(row["referenciaId"]) ?? "";
                string imagenUrl = Convert.ToString(row["imagenUrl"]) ?? "";

                try
                {
                    var tokens = ObtenerTokensUsuario(idEntidad, idUsuario);

                    if (tokens.Count == 0)
                    {
                        MarcarNotificacionError(
                            idNotificacionFCM,
                            "El usuario no tiene tokens FCM activos.");

                        continue;
                    }

                    var pushRequest = new FirebasePushRequest
                    {
                        Titulo = titulo,
                        Mensaje = mensaje,
                        ImagenUrl = string.IsNullOrWhiteSpace(imagenUrl) ? null : imagenUrl,
                        TipoNotificacion = tipoNotificacion,
                        ReferenciaTipo = referenciaTipo,
                        ReferenciaId = referenciaId,
                        Data = new Dictionary<string, string>
                        {
                            { "idNotificacionFCM", idNotificacionFCM.ToString() },
                            { "tipoNotificacion", tipoNotificacion },
                            { "referenciaTipo", referenciaTipo },
                            { "referenciaId", referenciaId },
                            { "pantalla", "detalle_cita" }
                        }
                    };

                    var results = await _firebasePushService.SendToTokensAsync(
                        tokens,
                        pushRequest,
                        cancellationToken);

                    int enviados = results.Count(x => x.Success);
                    int errores = results.Count(x => !x.Success);

                    if (enviados > 0)
                    {
                        string firebaseMessageId = string.Join(
                            " | ",
                            results
                                .Where(x => x.Success)
                                .Select(x => x.MessageId)
                                .Where(x => !string.IsNullOrWhiteSpace(x)));

                        MarcarNotificacionEnviada(
                            idNotificacionFCM,
                            firebaseMessageId);
                    }
                    else
                    {
                        string error = string.Join(
                            " | ",
                            results
                                .Where(x => !x.Success)
                                .Select(x => x.Error));

                        MarcarNotificacionError(
                            idNotificacionFCM,
                            error);
                    }

                    _logger.LogInformation(
                        "Notificación {IdNotificacion} procesada. Enviados: {Enviados}, Errores: {Errores}",
                        idNotificacionFCM,
                        enviados,
                        errores);
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "Error procesando notificación {IdNotificacion}",
                        idNotificacionFCM);

                    MarcarNotificacionError(
                        idNotificacionFCM,
                        ex.Message);
                }
            }
        }

        private List<string> ObtenerTokensUsuario(int? idEntidad, int idUsuario)
        {
            var tokens = new List<string>();

            var dtTokens = ExecuteDataTable("sp_se_tokenFCM", db =>
            {
                db.AddParameter("@idEntidad", idEntidad);
                db.AddParameter("@idUsuario", idUsuario);
                db.AddParameter("@soloActivos", true);
                db.AddParameter("@plataforma", "");
            });

            foreach (DataRow row in dtTokens.Rows)
            {
                var token = Convert.ToString(row["token"]);

                if (!string.IsNullOrWhiteSpace(token))
                    tokens.Add(token);
            }

            return tokens.Distinct().ToList();
        }

        private void MarcarNotificacionEnviada(
            int idNotificacionFCM,
            string firebaseMessageId)
        {
            ExecuteDataTable("sp_up_notificacionFCMEnviada", db =>
            {
                db.AddParameter("@idNotificacionFCM", idNotificacionFCM);
                db.AddParameter("@firebaseMessageId", firebaseMessageId);
                db.AddParameter("@idUsuarioModifica", 0);
                db.AddParameter("@comentarios", "Enviada automáticamente por BackgroundService");
            });
        }

        private void MarcarNotificacionError(
            int idNotificacionFCM,
            string error)
        {
            ExecuteDataTable("sp_up_notificacionFCMError", db =>
            {
                db.AddParameter("@idNotificacionFCM", idNotificacionFCM);
                db.AddParameter("@error", error);
                db.AddParameter("@idUsuarioModifica", 0);
            });
        }

        private DataTable ExecuteDataTable(
            string storedProcedure,
            Action<DataBase2> setParameters)
        {
            var db = new DataBase2();

            db.SetCommand(storedProcedure, true);
            setParameters(db);

            DataSet ds = db.ExecuteWithDataSet();

            if (ds == null || ds.Tables.Count == 0)
                return new DataTable();

            return ds.Tables[0];
        }
    }
}