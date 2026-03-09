using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyApi.Class.Auth
{

    public class ValidaUsuario
    {
        public int id { get; set; }
        public string username { get; set; } = "";
        public string password { get; set; } = "";
        public string comentarios { get; set; } = "";
        public int idUsuarioModifica { get; set; }

    }

    public class ExpiraSesionRequest
    {
        public int idEntidad { get; set; }
    }

    public class IniciarSesionUsuarioRequest
    {
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
        public string token { get; set; }
        public string ip { get; set; }
        public string userAgent { get; set; }
        public string comentarios { get; set; }
        public int idUsuarioAlta { get; set; }
        public int minutosSesion { get; set; } = 5;
    }

    public class ValidaSesionUsuarioRequest
    {
        public int idEntidad { get; set; }
        public string token { get; set; }
    }

    public class HeartbeatSesionUsuarioRequest
    {
        public int idEntidad { get; set; }
        public string token { get; set; }
        public int minutosSesion { get; set; } = 5;
    }

    public class CerrarSesionUsuarioRequest
    {
        public int idEntidad { get; set; }
        public string token { get; set; }
        public int? idUsuarioModifica { get; set; }
        public string comentarios { get; set; }
    }

    public class ObtenerSesionActivaUsuarioRequest
    {
        public int idEntidad { get; set; }
        public int idUsuario { get; set; }
    }

}
