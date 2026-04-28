namespace MyApi.Models.Notificacion
{
    #region Tokens FCM
    public class GuardaTokenFCMRequest
    {
        public int idUsuario { get; set; }
        public string token { get; set; } = "";
        public string dispositivo { get; set; } = "";
        public string plataforma { get; set; } = "";
        public string versionApp { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class ActualizaTokenUltimaConexionRequest
    {
        public int idUsuario { get; set; }
        public string token { get; set; } = "";
        public string dispositivo { get; set; } = "";
        public string plataforma { get; set; } = "";
        public string versionApp { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioModifica { get; set; }
    }

    public class ObtieneTokenFCMRequest
    {
        public int idEntidad { get; set; }
        public int idUsuario { get; set; } = 0;
        public bool soloActivos { get; set; } = true;
        public string plataforma { get; set; } = "";
    }

    public class DesactivaTokenFCMRequest
    {
        public int idEntidad { get; set; }
        public string token { get; set; } = "";
        public int idUsuario { get; set; } = 0;
        public int idUsuarioModifica { get; set; }
        public string comentarios { get; set; } = "";
    }

    #endregion

    #region Notificaciones FCM

    public class InsertaNotificacionFCMPorUsuarioRequest
    {
        public int idUsuario { get; set; }
        public string titulo { get; set; } = "";
        public string mensaje { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idEntidad { get; set; }
        public int idUsuarioAlta { get; set; }
    }

    public class InsertaNotificacionFCMPorEntidadRequest
    {
        public int idEntidad { get; set; }
        public string titulo { get; set; } = "";
        public string mensaje { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idUsuarioAlta { get; set; }
    }

    public class InsertaNotificacionFCMGeneralRequest
    {
        public string titulo { get; set; } = "";
        public string mensaje { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idUsuarioAlta { get; set; }
    }

    public class ObtieneNotificacionesPendientesRequest
    {
        public string tipo { get; set; } = "";
        public int idEntidad { get; set; } = 0;
        public int idUsuario { get; set; } = 0;
        public int top { get; set; } = 100;
        public bool incluirImagen { get; set; } = false;
    }

    public class MarcaNotificacionFCMEnviadaRequest
    {
        public int idNotificacionFCM { get; set; }
        public int idUsuarioModifica { get; set; }
        public string comentarios { get; set; } = "";
    }

    public class CancelaNotificacionFCMRequest
    {
        public int idNotificacionFCM { get; set; }
        public int idUsuarioModifica { get; set; }
        public string comentarios { get; set; } = "";
    }
    #endregion
}
